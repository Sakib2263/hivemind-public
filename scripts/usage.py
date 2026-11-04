#!/usr/bin/env python3
"""Usage tracker: how much each provider/model has used, and what's left, in one page (USAGE.md).

  python3 usage.py                 write USAGE.md (Hivemind root) and print it
  python3 usage.py brief           print only the "At a glance" table
  python3 usage.py watch           live view in a terminal, refreshed every minute (Mac/Linux "overlay")
  python3 usage.py ask             type in Claude/Antigravity % by hand, only when the live reading fails
  python3 usage.py note KEY VALUE  save one reading, e.g. note claude-session 40

Live quotas (real % used and reset times, read with the logins already on this PC):
  clanker-usage      Claude (5-hour + weekly, includes your chats in the app) and Antigravity, cached 5 min
  OpenRouter         free requests left today, when OPENROUTER_API_KEY is set
Local files, nothing sent anywhere:
  Claude Code logs   ~/.claude/projects/**/*.jsonl (Ubuntu and Windows)  tokens per message
  opencode           ~/.local/share/opencode (opencode.db or storage/message JSON)  tokens per message
  Codex              ~/.codex/sessions/**/*.jsonl  tokens (only once Codex is used)
  Relay ledger       logs/usage-ledger.csv  one line per worker try, written by relay.sh and autopilot.sh
  Readings           logs/usage-readings.csv  what you typed in with "ask" / "note"
  Limits             config/limits.env
"""
import csv, glob, json, os, re, shutil, sqlite3, subprocess, sys, urllib.request
from datetime import datetime, timedelta, timezone

KIT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEDGER = os.path.join(KIT, "logs", "usage-ledger.csv")
READINGS = os.path.join(KIT, "logs", "usage-readings.csv")
OUT = os.path.join(KIT, "USAGE.md")
OUT_JSON = os.path.join(KIT, "USAGE.json")   # read by the overlay (scripts/usage-overlay.ps1)
NOW = datetime.now().astimezone()
TZ = NOW.tzinfo
HOME = os.path.expanduser("~")


def env(path):
    d = {}
    try:
        for line in open(path, encoding="utf-8"):
            m = re.match(r'\s*([A-Z0-9_]+)="?([^"#\r\n]*)"?', line)
            if m:
                d[m.group(1)] = m.group(2).strip()
    except OSError:
        pass
    return d


L = env(os.path.join(KIT, "config", "limits.env"))
M = env(os.path.join(KIT, "config", "models.env"))
LOW = float(L.get("LOW_PCT") or 20)
FRESH = "fresh" in sys.argv[1:]


def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def when(dt):
    if dt is None:
        return "-"
    return dt.strftime("%H:%M") if dt.date() == NOW.date() else dt.strftime("%d %b %H:%M")


def k(n):
    n = n or 0
    return f"{n/1e6:.1f}M" if n >= 1e6 else f"{n/1e3:.0f}k" if n >= 1e3 else str(int(n))


def ts(v):
    """ISO string or epoch (s or ms) -> local aware datetime."""
    try:
        if isinstance(v, (int, float)):
            return datetime.fromtimestamp(v / 1000 if v > 1e11 else v, TZ)
        return datetime.fromisoformat(str(v).replace("Z", "+00:00")).astimezone(TZ)
    except (ValueError, OSError, OverflowError):
        return None


# ---------- periods ----------
DAY0 = NOW.replace(hour=0, minute=0, second=0, microsecond=0)
MONTH0 = DAY0.replace(day=1)
WEEK0 = DAY0 - timedelta(days=DAY0.weekday())


def claude_week_start():
    m = re.match(r"(mon|tue|wed|thu|fri|sat|sun)\w*\s+(\d{1,2}):(\d{2})", L.get("CLAUDE_WEEK_RESET", ""), re.I)
    if not m:
        return WEEK0, False
    wd = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"].index(m.group(1).lower())
    t = DAY0.replace(hour=int(m.group(2)), minute=int(m.group(3))) - timedelta(days=(NOW.weekday() - wd) % 7)
    return (t if t <= NOW else t - timedelta(days=7)), True


CWEEK0, CWEEK_SET = claude_week_start()


# ---------- token sources ----------
def claude_code():
    roots = [os.path.join(HOME, ".claude", "projects")] + glob.glob("/mnt/c/Users/*/.claude/projects")
    seen, rows = set(), []
    for root in roots:
        for f in glob.glob(os.path.join(root, "**", "*.jsonl"), recursive=True):
            try:
                fh = open(f, encoding="utf-8", errors="ignore")
            except OSError:
                continue
            for line in fh:
                if '"usage"' not in line:
                    continue
                try:
                    j = json.loads(line)
                except ValueError:
                    continue
                msg = j.get("message") or {}
                u = msg.get("usage")
                t = ts(j.get("timestamp"))
                if not u or not t:
                    continue
                key = (msg.get("id"), j.get("requestId"))
                if key[0] and key in seen:
                    continue
                seen.add(key)
                rows.append(dict(t=t, model=msg.get("model") or "?", i=u.get("input_tokens", 0),
                                 o=u.get("output_tokens", 0), cr=u.get("cache_read_input_tokens", 0),
                                 cw=u.get("cache_creation_input_tokens", 0)))
    return rows


def oc_row(j):
    tk = j.get("tokens")
    if not isinstance(tk, dict) or j.get("role", "assistant") != "assistant":
        return None
    t = ts((j.get("time") or {}).get("created"))
    if not t:
        return None
    c = tk.get("cache") or {}
    return dict(t=t, model=j.get("modelID") or "?", i=tk.get("input", 0) or 0,
                o=(tk.get("output", 0) or 0) + (tk.get("reasoning", 0) or 0),
                cr=c.get("read", 0) or 0, cw=c.get("write", 0) or 0, id=j.get("id"))


def opencode():
    base = os.environ.get("OPENCODE_DATA_DIR") or os.path.join(HOME, ".local", "share", "opencode")
    rows, seen = [], set()

    def add(j):
        r = oc_row(j)
        if r and (not r["id"] or r["id"] not in seen):
            seen.add(r["id"])
            rows.append(r)

    db = os.path.join(base, "opencode.db")
    if os.path.exists(db):  # newer opencode: SQLite. Schema varies, so look for JSON with "tokens" in any text column
        try:
            con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
            for (tab,) in con.execute("select name from sqlite_master where type='table'"):
                cols = [c[1] for c in con.execute(f'pragma table_info("{tab}")')]
                for col in cols:
                    try:
                        cur = con.execute(f'select "{col}" from "{tab}" where "{col}" like \'%"tokens"%\'')
                    except sqlite3.Error:
                        continue
                    for (v,) in cur:
                        try:
                            j = json.loads(v)
                        except (TypeError, ValueError):
                            continue
                        if isinstance(j, dict):
                            add(j)
            con.close()
        except sqlite3.Error:
            pass
    for f in glob.glob(os.path.join(base, "storage", "message", "*", "*.json")):  # older opencode: JSON files
        try:
            add(json.load(open(f, encoding="utf-8")))
        except (OSError, ValueError):
            pass
    return rows


def codex():
    rows, model = [], "codex"
    for f in glob.glob(os.path.join(HOME, ".codex", "sessions", "**", "*.jsonl"), recursive=True):
        for line in open(f, encoding="utf-8", errors="ignore"):
            try:
                j = json.loads(line)
            except ValueError:
                continue
            p = j.get("payload") or {}
            if p.get("model"):
                model = p["model"]
            u = (p.get("info") or {}).get("last_token_usage") if p.get("type") == "token_count" else None
            t = ts(j.get("timestamp"))
            if u and t:
                rows.append(dict(t=t, model=model, i=u.get("input_tokens", 0) - u.get("cached_input_tokens", 0),
                                 o=u.get("output_tokens", 0), cr=u.get("cached_input_tokens", 0), cw=0))
    return rows


def ledger():
    rows = []
    try:
        for r in csv.reader(open(LEDGER, encoding="utf-8")):
            if len(r) >= 8 and r[0].isdigit():
                spec = "opencode:free" if r[4] == "opencode" else r[4]  # no model header = the GLM default
                rows.append(dict(t=ts(int(r[0])), job=r[1], project=r[2], worker=r[3], spec=spec,
                                 exit=r[5], sec=num(r[6]) or 0, limit=r[7] == "1"))
    except OSError:
        pass
    return rows


def readings():
    last = {}
    try:
        for r in csv.reader(open(READINGS, encoding="utf-8")):
            if len(r) >= 3 and r[0].isdigit():
                last[r[1]] = (ts(int(r[0])), num(r[2]))
    except OSError:
        pass
    return last


def openrouter_live():
    keys = env(os.path.join(KIT, "secrets", "keys.env"))
    key = keys.get("OPENROUTER_API_KEY")
    if not key:
        return None
    try:
        req = urllib.request.Request("https://openrouter.ai/api/v1/key", headers={"Authorization": f"Bearer {key}"})
        d = json.load(urllib.request.urlopen(req, timeout=8)).get("data", {})
        f = d.get("free_model_daily_requests") or {}
        return f.get("used"), f.get("limit"), f.get("remaining")
    except Exception:
        return "error"


def live(provider):
    """usage-v1 document from clanker-usage (windows with used_pct and resets_at), or None.
    FRESH (usage.py fresh / overlay "Refresh now"): ask the provider now instead of using the 5-minute cache."""
    exe = shutil.which("clanker-usage") or os.path.join(HOME, ".local", "bin", "clanker-usage")
    if not os.path.exists(exe):
        return None
    try:
        r = subprocess.run([exe, provider, "json", "--max-age", "0" if FRESH else "300"], capture_output=True, text=True, timeout=45)
        doc = json.loads(r.stdout)
    except (OSError, ValueError, subprocess.SubprocessError):
        return None
    return doc if isinstance(doc, dict) else None


def until(dt):
    if not dt:
        return ""
    m = int((dt - NOW).total_seconds() // 60)
    if m <= 0:
        return "now"
    return f"{m // 1440}d {m % 1440 // 60}h" if m >= 1440 else f"{m // 60}h {m % 60:02d}m"


# ---------- sums ----------
def total(rows, since=None, until=None):
    s = dict(i=0, o=0, cr=0, cw=0, n=0)
    for r in rows:
        if (since and r["t"] < since) or (until and r["t"] >= until):
            continue
        for x in ("i", "o", "cr", "cw"):
            s[x] += r[x] or 0
        s["n"] += 1
    return s


def block(rows):
    """Current Claude 5-hour window, the way ccusage counts it: starts on the hour of the first message."""
    start = None
    for r in sorted(rows, key=lambda r: r["t"]):
        if start is None or r["t"] >= start + timedelta(hours=5):
            start = r["t"].replace(minute=0, second=0, microsecond=0)
    if start and NOW < start + timedelta(hours=5):
        return start
    return None


def status(left_pct=None, limited_at=None, unknown="ok"):
    if limited_at:
        return f"LIMIT HIT {when(limited_at)}"
    if left_pct is None:
        return unknown
    return "OUT" if left_pct <= 0 else "LOW" if left_pct < LOW else "ok"


# ---------- report ----------
def build():
    cc, oc, cx, lg, rd = claude_code(), opencode(), codex(), ledger(), readings()
    glance, out = [], []

    def reading(key, window):
        t, v = rd.get(key, (None, None))
        if v is None:
            return None, None, "not read yet"
        old = NOW - t > window
        return t, v, f"read {when(t)}" + (" (old, read again)" if old else "")

    def row(provider, window, used, left, st, pct=None, resets=None):
        glance.append(dict(provider=provider, window=window, used=used, left=left, status=st,
                           pct=pct, resets=resets.isoformat() if resets else None, until=until(resets)))

    def live_rows(label, doc, fallback):
        """Rows from a live quota; on failure, the typed-in readings (fallback: [(key, window name, hours)])."""
        wins = (doc or {}).get("windows") or []
        if doc and doc.get("status") != "unavailable" and wins:
            got = ts(doc.get("retrieved_at"))
            note = f"live {when(got)}" if doc.get("status") in ("live", "cached") else f"stale, from {when(got)}"
            for w in wins:
                u = float(w.get("used_pct") or 0)
                name = f"{w['scope']} {w['name']}" if w.get("scope") and w["scope"] != w["name"] else w["name"]
                row(label, name, f"{u:.0f}% ({note})", f"{100 - u:.0f}%", status(100 - u), u, ts(w.get("resets_at")))
            return True
        err = (doc or {}).get("error")
        for key, wname, hours in fallback:
            t, v, note = reading(key, timedelta(hours=hours))
            if err:
                note += "; live check failed: " + err[:60]
            row(label, wname, f"{v:.0f}% ({note})" if v is not None else note,
                f"{100 - v:.0f}%" if v is not None else "?", status(100 - v if v is not None else None, None, "?"), v)
        return False

    # Claude Pro (lead): live % from Anthropic (same numbers as Settings > Usage), else your readings
    cdoc = live("claude")
    live_rows("Claude Pro (lead)", cdoc, [("claude-session", "session (5-hour)", 5), ("claude-week", "weekly", 168)])
    b0 = block(cc)
    cb = total(cc, b0) if b0 else None
    cap = num(L.get("CLAUDE_CODE_TOKENS_5H"))
    if cb:
        used = cb["i"] + cb["o"] + cb["cw"]
        lp = max(0, 100 - used / cap * 100) if cap else None
        row("Claude Code tokens", f"window {when(b0)} to {when(b0 + timedelta(hours=5))}", f"{k(used)} tokens",
            f"{lp:.0f}%" if cap else "see Claude rows", status(lp), 100 - lp if cap else None, b0 + timedelta(hours=5))

    # relay workers
    for label, spec, budget_key, since, wname in (
        ("opencode GLM (free)", "opencode:free", "OPENCODE_FREE_JOBS_DAY", DAY0, "jobs today"),
        ("opencode DeepSeek (free2)", "opencode:free2", "OPENCODE_FREE2_JOBS_DAY", DAY0, "jobs today"),
        ("NVIDIA build (all nv models)", "opencode:nv", "NVIDIA_JOBS_DAY", DAY0, "jobs today"),
        ("Antigravity jobs", "agy", "AGY_JOBS_WEEK", WEEK0, "jobs this week"),
    ):
        js = [r for r in lg if r["t"] >= since and (r["spec"] == spec or (spec in ("agy", "opencode:nv") and r["spec"].startswith(spec)))]
        if spec.startswith("opencode:nv") and not js and not env(os.path.join(KIT, "secrets", "keys.env")).get("NVIDIA_API_KEY"):
            continue   # optional provider, not set up
        hit = max([r["t"] for r in js if r["limit"]], default=None)
        budget = num(L.get(budget_key))
        lp = max(0, 100 - len(js) / budget * 100) if budget else None
        row(label, wname, f"{len(js)} job" + "s" * (len(js) != 1),
            f"{max(0, budget - len(js)):.0f} jobs" if budget else "no published limit", status(lp, hit),
            100 - lp if budget else None, DAY0 + timedelta(days=1) if since == DAY0 else WEEK0 + timedelta(days=7))
    live_rows("Antigravity (Gemini)", live("agy"), [("agy-week", "weekly", 168)])

    orl = openrouter_live()
    if isinstance(orl, tuple) and orl[1]:
        u, lim, rem = orl
        utc0 = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
        row("OpenRouter free (PAL)", "requests today (UTC)", f"{u}", f"{rem} of {lim}",
            status(rem / lim * 100), u / lim * 100, utc0.astimezone(TZ))
    elif orl == "error":
        row("OpenRouter free (PAL)", "requests today (UTC)", "could not reach openrouter.ai", "?", "?")

    if L.get("CODEX_PLAN") or cx:
        live_rows("Codex", live("codex"), [])

    out.append(f"# Usage overview\nUpdated {NOW.strftime('%d %b %Y %H:%M')}. Refresh: `windows\shortcuts\\19 Usage.bat`, "
               "or it updates after every relay job.\n")
    out.append("## At a glance\n| Provider | Window | Used | Left | Resets in | Status |\n|---|---|---|---|---|---|")
    out += [f"| {g['provider']} | {g['window']} | {g['used']} | {g['left']} | {g['until'] or '-'} | {g['status']} |" for g in glance]
    prov = providers_state()
    miss = [p for p in prov if p["status"] != "ok"]
    if miss:
        out.append("\n**Not connected:** " + "; ".join(
            f"{p['provider']}{'' if p['needed'] else ' (optional)'}: {p['fix']}" for p in miss))
    out.append("\nClaude and Antigravity are read live (cached 5 min). Only what can be read automatically is tracked "
               "(Google Flow credits can't be, so they are not shown).\n")

    # token tables
    def table(title, rows, periods, note=""):
        if not rows:
            return
        out.append(f"## {title}\n{note}| Period | Input | Output | Cache read | Cache write | Messages |\n|---|---|---|---|---|---|")
        for name, s0 in periods:
            if s0 is None:
                continue
            s = total(rows, s0)
            out.append(f"| {name} | {k(s['i'])} | {k(s['o'])} | {k(s['cr'])} | {k(s['cw'])} | {s['n']} |")
        bym = {}
        for r in rows:
            if r["t"] >= MONTH0:
                bym.setdefault(r["model"], []).append(r)
        if bym:
            out.append("\nThis month by model:\n\n| Model | Today | This week | This month |\n|---|---|---|---|")
            for m in sorted(bym, key=lambda m: -sum(r["i"] + r["o"] for r in bym[m])):
                cells = [total(bym[m], s) for s in (DAY0, WEEK0, MONTH0)]
                out.append(f"| {m} | " + " | ".join(k(c["i"] + c["o"]) for c in cells) + " |")
        out.append("")

    wk = next((ts(w.get("resets_at")) for w in (cdoc or {}).get("windows") or [] if w.get("name") == "weekly" and not w.get("scope")), None)
    cweek0 = wk - timedelta(days=7) if wk else CWEEK0
    table("Claude Code tokens", cc,
          [("current 5-hour window", b0), ("today", DAY0), ("Claude week", cweek0), ("this month", MONTH0), ("all time", datetime.min.replace(tzinfo=TZ))],
          "Autopilot, `4 Claude Code - Open` and handoffs. Shares the Claude Pro quota with your chats in the app, "
          "which aren't logged on the PC.\n\n")
    table("opencode tokens (GLM, DeepSeek)", oc,
          [("today", DAY0), ("this week", WEEK0), ("this month", MONTH0), ("all time", datetime.min.replace(tzinfo=TZ))])
    table("Codex tokens", cx, [("today", DAY0), ("this week", WEEK0), ("this month", MONTH0)])

    # relay workers
    if lg:
        out.append("## Relay workers (one line per try)\n| Worker | Today | This week | This month | Limit hits (month) | Last limit hit | Hours worked (month) |\n|---|---|---|---|---|---|---|")
        specs = sorted({r["spec"] for r in lg if r["t"] >= MONTH0})
        for s in specs:
            rs = [r for r in lg if r["spec"] == s]
            m = [r for r in rs if r["t"] >= MONTH0]
            hits = [r["t"] for r in rs if r["limit"]]
            out.append(f"| {s} | {sum(r['t'] >= DAY0 for r in rs)} | {sum(r['t'] >= WEEK0 for r in rs)} | {len(m)} | "
                       f"{sum(r['limit'] for r in m)} | {when(max(hits)) if hits else '-'} | {sum(r['sec'] for r in m)/3600:.1f} |")
        out.append("")
    if cap is None and any(r["limit"] and r["spec"].startswith("claude") for r in lg):
        hit = max(r["t"] for r in lg if r["limit"] and r["spec"].startswith("claude"))
        hb = [r for r in cc if hit - timedelta(hours=5) <= r["t"] <= hit]
        s = total(hb)
        out.append(f"Calibration: Claude Code hit its limit at {when(hit)} after about {k(s['i'] + s['o'] + s['cw'])} tokens "
                   "in that window. Put that number in CLAUDE_CODE_TOKENS_5H (config/limits.env) to get a % gauge.\n")
    return "\n".join(out), glance, prov


def providers_state():
    """Which tools and keys are connected (scripts/providers.py), for the report and the overlay."""
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import providers
        return providers.check()
    except Exception:
        return []


def ask():
    print("Type a number, or press Enter to skip.\n")
    qs = []
    if not ((live("claude") or {}).get("windows")):
        qs += [("claude-session", "Claude: current session, % used (Settings > Usage)"),
               ("claude-week", "Claude: weekly limit, % used")]
    if not ((live("agy") or {}).get("windows")):
        qs += [("agy-week", "Antigravity: weekly quota, % used")]
    for key, q in qs:
        v = input(f"{q}: ").strip().rstrip("%")
        if v:
            note(key, v)


def note(key, value):
    if num(value) is None:
        print(f"skipped {key}: not a number")
        return
    os.makedirs(os.path.dirname(READINGS), exist_ok=True)
    with open(READINGS, "a", newline="", encoding="utf-8") as f:
        csv.writer(f).writerow([int(NOW.timestamp()), key, value])


def main():
    a = sys.argv[1:]
    if a[:1] == ["watch"]:
        import time
        print("Reading usage from each provider: up to a minute the first time...", flush=True)
        try:
            while True:
                r = subprocess.run([sys.executable, os.path.abspath(__file__), "brief"], capture_output=True, text=True)
                print("\033[2J\033[H" + r.stdout.strip() + "\n\nRefreshes every minute. Ctrl+C to close.", flush=True)
                time.sleep(60)
        except KeyboardInterrupt:
            return
    if a[:1] == ["note"] and len(a) == 3:
        note(a[1], a[2])
        return
    if a[:1] == ["ask"]:
        ask()
    text, glance, prov = build()
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(text + "\n")
    with open(OUT_JSON + ".tmp", "w", encoding="utf-8") as f:
        json.dump({"updated": NOW.isoformat(timespec="seconds"), "low_pct": LOW, "rows": glance, "providers": prov}, f, indent=1)
    os.replace(OUT_JSON + ".tmp", OUT_JSON)
    if a[:1] == ["brief"]:
        s = text.index("## At a glance")
        print(text[s:text.find("\n## ", s + 1)].strip())
    elif a[:1] != ["quiet"]:
        print(text)


if __name__ == "__main__":
    main()
