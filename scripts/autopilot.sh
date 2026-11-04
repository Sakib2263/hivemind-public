#!/usr/bin/env bash
# Autopilot: works through a project's TASKS.md unattended, one row per session, until the board is done,
# the owner stops it, or the time budget runs out. Each step is a fresh headless session (no long chat,
# no permission prompts: tools outside the allow-list are simply refused).
#   bash autopilot.sh <project dir (WSL path)> [hours, default 8]
# Stop: windows\shortcuts\18 Stop Autopilot.bat (creates relay/AUTOPILOT.stop), or close the window.
# Claude out of quota: that step goes to the free opencode models; if they fail too, wait and retry.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
. "$KIT/config/models.env"
DIR="$1"; HOURS="${2:-8}"
cd "$DIR" 2>/dev/null || { echo "Folder not found: $DIR"; exit 1; }
[ -f TASKS.md ] || { echo "No TASKS.md in $DIR: nothing to continue."; exit 1; }
STOP="$KIT/relay/AUTOPILOT.stop"; rm -f "$STOP" "$DIR/AUTOPILOT.stop"
LOGD="$KIT/logs/autopilot"; mkdir -p "$LOGD"
( while kill -0 $$ 2>/dev/null; do date +%s > "$KIT/relay/activity"; sleep 60; done ) &   # keeps the computer awake while autopilot runs
LOG="$LOGD/$(basename "$DIR" | tr ' ' '_')-$(date +%Y%m%d-%H%M).log"
END=$(( $(date +%s) + HOURS * 3600 )); STEP_MAX="${AUTOPILOT_STEP_SECONDS:-3600}"
LIMIT='rate.?limit|429|quota|usage limit|limit reached|too many requests|overloaded|503|not logged in'
ALLOW="Read,Edit,Write,Glob,Grep,TodoWrite,WebSearch,WebFetch,Bash(python3:*),Bash(node:*),Bash(npm:*),Bash(npx:*),Bash(git status:*),Bash(git diff:*),Bash(git log:*),Bash(git add:*),Bash(git commit:*),Bash(ls:*),Bash(cat:*),Bash(head:*),Bash(tail:*),Bash(grep:*),Bash(find:*),Bash(wc:*),Bash(mkdir:*),Bash(cp:*),Bash(mv:*),Bash(ffmpeg:*),Bash(ffprobe:*),Bash(date:*)"
DENY="Bash(rm:*),Bash(git push:*),Bash(git reset:*),Bash(git checkout:*),Bash(git clean:*),Bash(curl:*),Bash(wget:*),Bash(sudo:*),Bash(ssh:*),Bash(scp:*)"

prompt() { cat <<P
AUTOPILOT step $1. You lead Hivemind, working unattended: the owner is away and will not answer questions.
Project folder: $DIR. Hivemind: $KIT.
1. Read CLAUDE.md or AGENTS.md, then TASKS.md (start from the Handoff), PLAN.md if present, and $KIT/templates/ROUTING.md.
2. Pick the next open row you can finish without the owner. Skip rows that need the owner (logins, payments,
   uploads, publishing, approvals, listening, choices only the owner can make).
3. Do it completely: build, test, fix what you broke. Use relay workers only if $KIT/relay/heartbeat is under a
   minute old; otherwise do it yourself. Edit Hivemind files only when the row is about Hivemind itself.
4. Never: delete files, push, publish or upload anything, spend money or Flow credits, touch secrets or other projects.
   A local git commit of finished, tested work is fine.
5. Update TASKS.md (row status + Handoff) and add one line to logs/LOG.md if that file exists.
6. End with exactly one last line: AUTOPILOT: CONTINUE | AUTOPILOT: ALL DONE | AUTOPILOT: NEEDS OWNER <one-line question> | AUTOPILOT: BLOCKED <reason>
P
}

say() { echo "[$(date +%H:%M)] $*" | tee -a "$LOG"; }
ledger() {  # $1 spec $2 exit $3 start: one line in logs/usage-ledger.csv, then refresh USAGE.md
  local lim=0; [ "$2" -ne 0 ] && grep -qiE "$LIMIT" "$out" && lim=1
  echo "$(date +%s),autopilot-$n,$(basename "$DIR" | tr ',' ' '),autopilot,$1,$2,$(( $(date +%s) - $3 )),$lim" >> "$KIT/logs/usage-ledger.csv"
  python3 "$KIT/scripts/usage.py" quiet >/dev/null 2>&1
}
say "Autopilot on $DIR for $HOURS h. Log: $LOG. Stop: windows\shortcuts\\18 Stop Autopilot.bat"
n=0; waits=0
while :; do
  [ -f "$STOP" ] || [ -f "$DIR/AUTOPILOT.stop" ] && { say "Stopped by the owner."; break; }
  [ "$(date +%s)" -ge "$END" ] && { say "Time budget used up ($HOURS h)."; break; }
  n=$((n+1)); P="$(prompt $n)"; out="$LOGD/.step.out"
  say "step $n: claude"; t0="$(date +%s)"
  timeout "$STEP_MAX" claude -p "$P" --permission-mode acceptEdits --add-dir "$KIT" \
    --allowedTools "$ALLOW" --disallowedTools "$DENY" ${AUTOPILOT_MODEL:+--model "$AUTOPILOT_MODEL"} < /dev/null > "$out" 2>&1
  code=$?; ledger claude $code "$t0"
  if [ $code -ne 0 ] && grep -qiE "$LIMIT" "$out"; then
    say "Claude is out of quota; this step goes to the free models."
    for s in free free2; do
      m="$OPENCODE_FREE_MODEL"; [ $s = free2 ] && m="$OPENCODE_FREE2_MODEL"
      [ -z "$m" ] && continue; say "step $n: opencode $m"; t0="$(date +%s)"
      timeout "${OPENCODE_MAX_SECONDS:-900}" opencode run -m "$m" "$P" < /dev/null > "$out" 2>&1; c=$?; ledger "opencode:$s" $c "$t0"
      [ $c -eq 0 ] && { code=0; break; }
    done
  fi
  cat "$out" >> "$LOG"
  st="$(grep -o 'AUTOPILOT: [A-Z][A-Z ]*.*' "$out" | tail -1)"
  if [ $code -ne 0 ] && [ -z "$st" ]; then
    waits=$((waits+1)); [ $waits -gt 8 ] && { say "Too many failed steps in a row; stopping."; break; }
    say "Step failed (exit $code). Waiting 20 min, then retrying."; sleep 1200; continue
  fi
  waits=0; say "step $n: ${st:-no status line (treated as CONTINUE)}"
  case "$st" in
    "AUTOPILOT: ALL DONE"*) say "Board done."; break ;;
    "AUTOPILOT: NEEDS OWNER"*|"AUTOPILOT: BLOCKED"*) say "Waiting for the owner: see TASKS.md Handoff."; break ;;
  esac
  sleep 5
done
rm -f "$out"; say "Autopilot finished after $n step(s)."
