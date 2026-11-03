#!/usr/bin/env python3
"""Providers: which AI tools and keys are connected, and the keys file.

  python3 providers.py status          what's connected, what's missing and how to add it (exit 1 if a needed one is missing)
  python3 providers.py json            the same as JSON (used by usage.py, shown in the usage overlay)
  python3 providers.py sync-template   add key lines that are new in keys.env.template to secrets/keys.env (values kept)
  python3 providers.py set NAME        read a key from the keyboard (hidden) and save it in secrets/keys.env
  python3 providers.py opencode-auth   give opencode the keys from secrets/keys.env: OPENCODE_API_KEY (OpenCode Zen) and
                                       NVIDIA_API_KEY (build.nvidia.com free endpoints, provider "nvidia" in opencode)
  python3 providers.py nvidia-check    ask build.nvidia.com whether the NVIDIA models in config/models.env still exist
Only looks at local files; nothing is sent anywhere (except nvidia-check, which asks NVIDIA's model list).
"""
import glob, json, os, re, shutil, sys

KIT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KEYS = os.path.join(KIT, "secrets", "keys.env")
TEMPLATE = os.path.join(KIT, "secrets", "keys.env.template")
HOME = os.path.expanduser("~")
OC_CONF = os.path.join(os.environ.get("XDG_CONFIG_HOME") or os.path.join(HOME, ".config"), "opencode", "opencode.json")
NV_URL = "https://integrate.api.nvidia.com/v1"
OC_AUTH = os.path.join(os.environ.get("XDG_DATA_HOME") or os.path.join(HOME, ".local", "share"), "opencode", "auth.json")
WIN = "microsoft" in open("/proc/version").read().lower() if os.path.exists("/proc/version") else False
SH = "windows\\" if WIN else "mac-linux/"          # where the launchers are
EXT = ".bat" if WIN else ""


def keys():
    d = {}
    try:
        for line in open(KEYS, encoding="utf-8-sig"):
            m = re.match(r"\s*([A-Z0-9_]+)\s*=\s*(.*?)\s*$", line)
            if m and not line.lstrip().startswith("#"):
                d[m.group(1)] = m.group(2).strip().strip('"').strip("'")
    except OSError:
        pass
    return d


def which(cmd):
    extra = [os.path.join(HOME, ".local", "bin"), os.path.join(HOME, ".opencode", "bin"), "/usr/local/bin"]
    extra += sorted(glob.glob(os.path.join(HOME, ".nvm", "versions", "node", "*", "bin")), reverse=True)
    return shutil.which(cmd) or shutil.which(cmd, path=os.pathsep.join(extra))


def oc_key_in_auth(provider="opencode"):
    try:
        e = json.load(open(OC_AUTH, encoding="utf-8")).get(provider) or {}
        return bool(e.get("key") or e.get("access"))
    except (OSError, ValueError, AttributeError):
        return False


def models_env():
    d = {}
    try:
        for line in open(os.path.join(KIT, "config", "models.env"), encoding="utf-8"):
            m = re.match(r'\s*([A-Z0-9_]+)="?([^"#\r\n]*)"?', line)
            if m:
                d[m.group(1)] = m.group(2).strip()
    except OSError:
        pass
    return d


def check():
    k = keys()
    login, addkeys, install = f"{SH}3 Log In{EXT}", f"{SH}4 Add API Keys{EXT}", f"{SH}2 Install AI Tools{EXT}"
    rows = []

    def add(name, need, installed, connected, fix, does):
        st = "ok" if installed and connected else "not installed" if not installed else "not connected"
        rows.append(dict(provider=name, needed=need, status=st, does=does,
                         fix="" if st == "ok" else (f"run {install}" if not installed else fix)))

    add("Claude Code", True, which("claude"), os.path.exists(os.path.join(HOME, ".claude", ".credentials.json")),
        f"run {login} (step 1)", "autopilot, handoffs, Claude Code - Open")
    add("opencode (GLM, DeepSeek free)", True, which("opencode"), oc_key_in_auth() or bool(k.get("OPENCODE_API_KEY")),
        f"free key from opencode.ai: run {login} (step 3) or put it in OPENCODE_API_KEY with {addkeys}", "main builders")
    add("Antigravity (Gemini)", True, which("agy"), os.path.isdir(os.path.join(HOME, ".gemini", "antigravity-cli")),
        f"run {login} (step 2), Google account", "reviews, reading, second opinions")
    add("Codex (ChatGPT)", False, which("codex"), os.path.exists(os.path.join(HOME, ".codex", "auth.json")),
        f"any ChatGPT login, free works: run {login} (step 4)", "extra builder and reviewer in the fallback chains")
    add("NVIDIA (build.nvidia.com)", False, which("opencode"), oc_key_in_auth("nvidia") and bool(k.get("NVIDIA_API_KEY")),
        f"free key at build.nvidia.com (sign in > Get API Key, starts nvapi-), then {addkeys}",
        "extra free builders and reviewers (MiniMax, Nemotron); rate-limited per minute")
    add("OpenRouter (PAL)", False, True, bool(k.get("OPENROUTER_API_KEY")),
        f"free key at openrouter.ai > Keys, then {addkeys}", "extra free models")
    add("DeepSeek API", False, True, bool(k.get("DEEPSEEK_API_KEY")),
        f"key at platform.deepseek.com (pay per use), then {addkeys}", "deepseek worker, last in the chains")
    return rows


def status():
    rows = check()
    print("=== Providers ===")
    for r in rows:
        mark = "[OK]  " if r["status"] == "ok" else "[MISSING]" if r["needed"] else "[off] "
        print(f"{mark:9} {r['provider']:30} {r['status'] if r['status'] != 'ok' else r['does']}")
    miss = [r for r in rows if r["status"] != "ok"]
    if miss:
        print("\nAdd in a few minutes:")
        for r in miss:
            print(f"  - {r['provider']}{'' if r['needed'] else ' (optional)'}: {r['fix']}")
    if any(r["needed"] for r in miss):
        print("\nThe relay still runs: jobs for a missing worker fall back to the next one in its chain.")
        return 1
    return 0


def sync_template():
    if not os.path.exists(KEYS):
        os.makedirs(os.path.dirname(KEYS), exist_ok=True)
        open(KEYS, "w", encoding="utf-8").write(open(TEMPLATE, encoding="utf-8").read())
        return
    have, tpl = keys(), open(TEMPLATE, encoding="utf-8").read().splitlines()
    new = [l for l in tpl if re.match(r"^[A-Z0-9_]+=", l) and l.split("=")[0] not in have]
    if new:
        txt = open(KEYS, encoding="utf-8-sig").read()
        with open(KEYS, "w", encoding="utf-8") as f:
            f.write(txt.rstrip("\r\n") + "\n" + "\n".join(new) + "\n")
        print("Added to secrets/keys.env: " + ", ".join(l.split("=")[0] for l in new))


def clean(v):
    v = re.sub(r"\x1b\[[0-9;]*[~A-Za-z]", "", v)          # terminal paste markers
    return re.sub(r"[\s\"']", "", v)


def set_key(name, value=None):
    if value is None:
        import getpass
        value = getpass.getpass("Paste the key (right-click to paste in a Windows console), then Enter. It stays hidden: ")
    value = clean(value)
    if not value:
        print("Nothing pasted: nothing saved.")
        return 1
    sync_template()
    lines, done = open(KEYS, encoding="utf-8-sig").read().splitlines(), False
    for i, l in enumerate(lines):
        if re.match(rf"^\s*{name}\s*=", l):
            lines[i], done = f"{name}={value}", True
    if not done:
        lines.append(f"{name}={value}")
    with open(KEYS, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    os.chmod(KEYS, 0o600)
    print(f"Saved {name} ({len(value)} characters, ends ...{value[-4:]}) in secrets/keys.env")
    return 0


def nv_models():
    m = models_env()
    return [v for v in (m.get("NVIDIA_MODEL"), m.get("NVIDIA_MODEL2")) if v]


def nvidia_provider():
    """Adds (or refreshes) the "nvidia" provider in opencode's own config: OpenAI-compatible, models from models.env.
    The key itself stays in auth.json, never in this file."""
    try:
        conf = json.load(open(OC_CONF, encoding="utf-8")) if os.path.exists(OC_CONF) else {}
    except ValueError:
        print(f"[SKIP] {OC_CONF} has comments or isn't plain JSON: add the nvidia provider by hand (see templates/routing/models.md)")
        return
    conf.setdefault("$schema", "https://opencode.ai/config.json")
    prov = conf.setdefault("provider", {})
    nv = prov.setdefault("nvidia", {})
    nv.update({"npm": "@ai-sdk/openai-compatible", "name": "NVIDIA build (free endpoints)"})
    nv.setdefault("options", {})["baseURL"] = NV_URL
    models = nv.setdefault("models", {})
    for full in nv_models():
        mid = full.split("/", 1)[1] if full.startswith("nvidia/") else full
        models.setdefault(mid, {"name": mid})
    os.makedirs(os.path.dirname(OC_CONF), exist_ok=True)
    with open(OC_CONF, "w", encoding="utf-8") as f:
        json.dump(conf, f, indent=2)


def opencode_auth():
    k = keys()
    pairs = [(p, k.get(n), msg) for p, n, msg in (("opencode", "OPENCODE_API_KEY", "OpenCode Zen key set (free models)"),
                                                  ("nvidia", "NVIDIA_API_KEY", "NVIDIA key set (build.nvidia.com free endpoints)"))]
    if not any(v for _, v, _ in pairs):
        return 0
    try:
        d = json.load(open(OC_AUTH, encoding="utf-8"))
    except (OSError, ValueError):
        d = {}
    for prov, key, msg in pairs:
        if key:
            d[prov] = {"type": "api", "key": key}
            print(f"[OK]   opencode: {msg}")
    os.makedirs(os.path.dirname(OC_AUTH), exist_ok=True)
    with open(OC_AUTH, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=2)
    os.chmod(OC_AUTH, 0o600)
    if k.get("NVIDIA_API_KEY"):
        nvidia_provider()
    return 0


def nvidia_check():
    key = keys().get("NVIDIA_API_KEY")
    if not key:
        print("NVIDIA:         off (optional: free key at build.nvidia.com)")
        return 0
    import urllib.request
    try:
        req = urllib.request.Request(NV_URL + "/models", headers={"Authorization": f"Bearer {key}"})
        ids = {m.get("id") for m in json.load(urllib.request.urlopen(req, timeout=20)).get("data", [])}
    except Exception as e:
        print(f"NVIDIA:         could not read the model list ({str(e)[:80]})")
        return 1
    bad = 0
    for full in nv_models():
        mid = full.split("/", 1)[1] if full.startswith("nvidia/") else full
        ok = mid in ids
        bad += not ok
        print(f"NVIDIA model:   {mid}: {'available' if ok else 'NOT LISTED: pick another id in config/models.env'}")
    if bad:
        cands = sorted(i for i in ids if re.search(r"coder|glm|minimax|deepseek|nemotron.*(super|ultra)|kimi|qwen", i or "", re.I))
        print("  Candidates: " + ", ".join(cands[:15]))
    return 1 if bad else 0


if __name__ == "__main__":
    a = sys.argv[1:] or ["status"]
    if a[0] == "json":
        print(json.dumps(check()))
    elif a[0] == "sync-template":
        sync_template()
    elif a[0] == "set" and len(a) >= 2:
        sys.exit(set_key(a[1], a[2] if len(a) > 2 else None))
    elif a[0] == "opencode-auth":
        sys.exit(opencode_auth())
    elif a[0] == "nvidia-check":
        sys.exit(nvidia_check())
    else:
        sys.exit(status())
