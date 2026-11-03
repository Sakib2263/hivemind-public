#!/usr/bin/env bash
# Relay: Claude (desktop app) drops job files in relay/inbox, this script runs them with the
# worker named in the job and writes results to relay/outbox.
# Start once in an Ubuntu window and leave it open (Ctrl+C to stop): windows\shortcuts\1 Start Relay.bat
#
# Job file: relay/inbox/<id>.job
#   worker: opencode | agy | review | gate | graph | git-commit | android | files | upload | install | comfy | video   (codex, codex-review, deepseek: when those plans/keys exist)
#   dir:    <project folder in WSL form>   (must be inside the work folder that holds this kit)
#   model:  opencode: free | free2 | nv | nv2 | <model id>.  agy: hard.  gate/review: engine list, e.g. "agy opencode:free"
#   gate:   build | security | release     (gate only, see gates/)
#   base:   main  / commit: <sha>          (review only; default = uncommitted changes)
#   effort: medium                         (codex only)
#   fallback: opencode:free2 agy | none    (optional; default chains are in config/models.env)
#   ---
#   <handoff: Task / Scope / Start from / Done when>  (git-commit: one-line message; graph: "update" or a question; android: debug or release)
#   files: one "delete <path>" per line.  upload: line 1 file path, line 2 signed https amazonaws.com PUT url.
#   install: apk path (empty = newest builds/android/*.apk), installed on the USB phone with Windows adb.
#   files, upload, install, git-commit and android are plain scripts: no AI model, instant, never stall.
#
# Automatic fallback: when a model fails because of a limit, quota, login or missing tool, the relay tries the
# next one in the chain by itself. Real errors (a failing build, a bad prompt) are reported, not retried.
#
# Results in relay/outbox/<id>.*  Read in this order, stop when you have enough:
#   .done (exit code, seconds) -> .last (short final answer) -> .git (status + diff stat)
#   -> .diff (full diff) -> .out (full log, only when something failed)
# Up to RELAY_MAX_JOBS jobs run at once (default 2), never two in the same project folder.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
R="$ROOT/relay"; IN="$R/inbox"; OUT="$R/outbox"; DONE="$R/done"; LOCKS="$R/locks"
mkdir -p "$IN" "$OUT" "$DONE" "$LOCKS"
rm -rf "$LOCKS"/* 2>/dev/null   # locks left by a relay that was closed mid-job
export PATH="$HOME/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null
ALLOWED_ROOT="$(dirname "$ROOT")"   # the work folder that contains this kit
allowed_dir() {  # inside the work folder or a folder from config/folders.env, and never inside Hivemind itself
  local d="$1" r roots=("$ALLOWED_ROOT") w
  [[ "$d" == "$ROOT" || "$d" == "$ROOT"/* ]] && return 1
  if [ -f "$ROOT/config/folders.env" ]; then
    w="$(sed -n 's/^WORK_FOLDERS="\(.*\)"/\1/p' "$ROOT/config/folders.env" | tr -d '\r')"
    IFS=';' read -ra extra <<< "$w"
    for r in "${extra[@]}"; do [ -n "$r" ] || continue; [[ "$r" =~ ^[A-Za-z]: ]] && r="$(wslpath -u "$r")"; roots+=("$(realpath -m "$r")"); done
  fi
  for r in "${roots[@]}"; do [[ "$d" == "$r"/* ]] && return 0; done
  return 1
}
MAX_SECONDS=2700                    # 45 min per job
MAX_JOBS="${RELAY_MAX_JOBS:-2}"
export HIVEMIND="$ROOT"   # workers and gates can run kit scripts: $HIVEMIND/scripts/...
WORKERS="opencode agy review gate graph git-commit android files upload install comfy video codex codex-review deepseek"

field() { sed -n "1,/^---$/p" "$1" | grep -i "^$2:" | head -1 | cut -d: -f2- | sed 's/^ *//; s/ *$//'; }
body()  { sed '1,/^---$/d' "$1"; }

load_config() {  # models register + the DeepSeek key, re-read for every job so edits apply without restart
  # Only DEEPSEEK_API_KEY is exported: an OPENAI_API_KEY in the environment could make Codex bill the API instead of your plan.
  [ -f "$ROOT/config/models.env" ] && { set -a; . "$ROOT/config/models.env"; set +a; }
  if [ -f "$ROOT/secrets/keys.env" ]; then
    while IFS= read -r line; do export "$line"; done < <(tr -d '\r' < "$ROOT/secrets/keys.env" | grep -E '^DEEPSEEK_API_KEY=.+')
  fi
}

status_board() {  # relay/STATUS.md: one line per recent job, so Claude reads one file instead of polling each job
  local tmp="$R/.status.$BASHPID" f id
  { echo "# Relay status $(date '+%d %b %H:%M'), newest first"
    ls -t "$OUT"/*.running "$OUT"/*.done 2>/dev/null | head -20 | while IFS= read -r f; do
      id="$(basename "${f%.*}")"
      case "$f" in *.running) echo "RUNNING $id" ;;
        *) echo "DONE $id | $(cat "$f") | $(tail -1 "$OUT/$id.last" 2>/dev/null)" ;; esac
    done; } > "$tmp" && mv -f "$tmp" "$R/STATUS.md"
}

finish() {  # $1 res  $2 exit code  $3 start time  $4 lock
  [ -s "$1.last" ] || tail -n 60 "$1.out" > "$1.last" 2>/dev/null
  echo "exit: $2  seconds: $(( $(date +%s) - $3 ))" > "$1.done"
  rm -f "$1.running"; rmdir "$4" 2>/dev/null
  status_board
}

refuse() {  # $1 id  $2 message
  echo "REFUSED: $2" | tee "$OUT/$1.out" > "$OUT/$1.last"; echo "exit: 2  seconds: 0" > "$OUT/$1.done"; status_board
  echo "[$(date +%H:%M:%S)] job $1 refused: $2"
}

oc_model() {  # opencode model shortcut -> model id
  case "$1" in
    ""|free) echo "$OPENCODE_FREE_MODEL" ;;
    free2) echo "$OPENCODE_FREE2_MODEL" ;;
    nv) echo "$NVIDIA_MODEL" ;;
    nv2) echo "$NVIDIA_MODEL2" ;;
    copilot) echo "$OPENCODE_COPILOT_MODEL" ;;
    gemini) echo "$OPENCODE_GEMINI_MODEL" ;;
    *) echo "$1" ;;
  esac
}

oc_run() {  # $1 model shortcut or id, $2 prompt
  local m; m="$(oc_model "$1")"
  if [ -z "$m" ]; then echo "model unavailable: no model set for '${1:-free}' in config/models.env (list ids: opencode models opencode)"; return 1; fi
  if [[ "$m" == nvidia/* ]] && ! grep -q '"nvidia"' "${XDG_DATA_HOME:-$HOME/.local/share}/opencode/auth.json" 2>/dev/null; then
    echo "model unavailable: no NVIDIA key (optional: build.nvidia.com, then 4 Add API Keys)"; return 1; fi
  # Stall watchdog: stop when there's no new output and no file change in the project for OPENCODE_IDLE_SECONDS
  # (default 6 min), or after OPENCODE_MAX_SECONDS in total. Exit 124 = stalled; the next model in the chain tries.
  local log mark pid idle=0 t=0 last=-1 size
  log="$(mktemp)"; mark="$(mktemp)"
  opencode run -m "$m" "$2" < /dev/null > "$log" 2>&1 & pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    sleep 15; t=$((t + 15)); size="$(stat -c %s "$log")"
    if [ "$size" != "$last" ] || [ -n "$(find "${real:-.}" -path '*/.git' -prune -o -type f -newer "$mark" -print -quit 2>/dev/null)" ]; then
      idle=0; last="$size"; touch "$mark"
    else idle=$((idle + 15)); fi
    if [ "$idle" -ge "${OPENCODE_IDLE_SECONDS:-360}" ] || [ "$t" -ge "${OPENCODE_MAX_SECONDS:-2700}" ]; then
      pkill -P "$pid" 2>/dev/null; kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
      cat "$log"; rm -f "$log" "$mark"; echo "stalled: no progress for ${idle}s (${t}s in total)"; return 124
    fi
  done
  wait "$pid"; local rc=$?; cat "$log"; rm -f "$log" "$mark"; return $rc
}

attempt() {  # one try: $1 worker  $2 model (for gate/review: engine[:model])  -> output on stdout
  local w="$1" m="$2"
  local cargs=(exec --skip-git-repo-check -C "$real" -c model_reasoning_effort="${effort:-$CODEX_EFFORT_DEFAULT}" -o "$res.last")
  [ -n "$CODEX_MODEL" ] && cargs+=(-m "$CODEX_MODEL")
  local rargs=(--uncommitted); [ -n "$base" ] && rargs=(--base "$base"); [ -n "$commit" ] && rargs=(--commit "$commit")
  case "$w" in
    codex)
      timeout "$MAX_SECONDS" codex "${cargs[@]}" --sandbox workspace-write "$prompt" < /dev/null 2>&1 ;;
    codex-review)
      timeout "$MAX_SECONDS" codex review "${rargs[@]}" < /dev/null 2>&1 ;;
    gate|review)
      # the check text + the task, run by an engine: opencode[:model] | agy[:hard] | codex
      local text eng="${m%%:*}" em=""; [[ "$m" == *:* ]] && em="${m#*:}"
      if [ "$w" = gate ]; then text="$(cat "$ROOT/gates/$gate.md")"$'\n\n## Task being checked\n'"$prompt"
      else text="$(cat "$ROOT/gates/review.md")"$'\n\n## What to review\n'"${prompt:-The uncommitted changes (git diff).}"
        [ -n "$base" ] && text="$text"$'\nCompare against branch: '"$base"
        [ -n "$commit" ] && text="$text"$'\nReview commit: '"$commit"; fi
      case "$eng" in
        codex)
          if [ "$w" = review ]; then timeout "$MAX_SECONDS" codex review "${rargs[@]}" < /dev/null 2>&1
          else local sb="workspace-write"; [ "$gate" = "security" ] && sb="read-only"
            timeout "$MAX_SECONDS" codex "${cargs[@]}" --sandbox "$sb" "$text" < /dev/null 2>&1; fi ;;
        agy)
          if [ "$em" = hard ]; then timeout "$MAX_SECONDS" agy -p "$text" --model "$AGY_MODEL_HARD" < /dev/null 2>&1
          else timeout "$MAX_SECONDS" agy -p "$text" < /dev/null 2>&1; fi ;;
        *) oc_run "$em" "$text" ;;
      esac ;;
    deepseek)
      local dm="${m:-$DEEPSEEK_MODEL}"; [ "$m" = "hard" ] && dm="$DEEPSEEK_MODEL_HARD"
      if [ -z "$DEEPSEEK_API_KEY" ]; then echo "model unavailable: no DEEPSEEK_API_KEY (pay-per-use, off for now)"; return 1; fi
      timeout "$MAX_SECONDS" opencode run -m "$dm" "$prompt" < /dev/null 2>&1 ;;
    opencode)
      oc_run "$m" "$prompt" ;;
    agy)
      local am="$m"; [ "$m" = "hard" ] && am="$AGY_MODEL_HARD"
      if [ -n "$am" ]; then timeout "$MAX_SECONDS" agy -p "$prompt" --model "$am" < /dev/null 2>&1
      else timeout "$MAX_SECONDS" agy -p "$prompt" < /dev/null 2>&1; fi ;;
    graph)
      # "update" (or empty) = build or refresh graphify-out/; anything else = a question to the graph
      local q; q="$(printf '%s' "$prompt" | head -1 | tr -d '[:space:]')"
      if [ -z "$q" ] || [ "$q" = "update" ] || [ "$q" = "build" ]; then
        if [ -d graphify-out ]; then timeout "$MAX_SECONDS" graphify . --update < /dev/null 2>&1
        else timeout "$MAX_SECONDS" graphify . < /dev/null 2>&1; fi
      else timeout "$MAX_SECONDS" graphify query "$prompt" < /dev/null 2>&1; fi ;;
    android)
      # body: "debug" (test APK) or "release" (signed AAB + APK). Never asks: missing facts come back as MISSING (exit 3)
      local mode; mode="$(printf '%s' "$prompt" | head -1 | tr -d '[:space:]')"
      timeout "$MAX_SECONDS" bash "$ROOT/scripts/android-build.sh" "$real" "${mode:-debug}" < /dev/null 2>&1 ;;
    git-commit)
      # prompt = one-line commit message; commits every change in this repo, nothing else
      local msg; msg="$(printf '%s' "$prompt" | head -1 | cut -c1-200)"
      if [ -z "$msg" ] || ! git rev-parse --git-dir >/dev/null 2>&1; then echo "REFUSED: need a commit message and a git repo"; return 1; fi
      git add -A && git commit -m "$msg" && git log --oneline -3 ;;
    files)
      # one "delete <path>" per line, relative to the project; only files inside it, never .git
      local line p f n=0
      while IFS= read -r line; do
        line="${line%$'\r'}"; [ -z "$line" ] && continue
        case "$line" in "delete "*) p="${line#delete }" ;; *) echo "REFUSED line: $line (only: delete <path>)"; return 1 ;; esac
        f="$(realpath -m "$real/$p")"
        [[ "$f" == "$real"/* && "$f" != "$real/.git" && "$f" != "$real"/.git/* ]] || { echo "REFUSED: $p is outside the project"; return 1; }
        if [ -f "$f" ]; then rm -f "$f" && echo "deleted $p" && n=$((n+1)); else echo "not found: $p"; fi
      done <<< "$prompt"
      echo "files: $n deleted" ;;
    upload)
      # line 1: file inside the project; line 2: signed https PUT url (Playgama archive or cover upload)
      local p u f ct code
      p="$(printf '%s\n' "$prompt" | sed -n 1p | tr -d '\r')"; u="$(printf '%s\n' "$prompt" | sed -n 2p | tr -d '\r')"
      f="$(realpath -m "$real/$p")"
      [[ "$f" == "$real"/* && -f "$f" ]] || { echo "REFUSED: file not found in the project: $p"; return 1; }
      [[ "$u" =~ ^https://[A-Za-z0-9.-]+\.amazonaws\.com/ ]] || { echo "REFUSED: url must be a signed https amazonaws.com url"; return 1; }
      ct="application/octet-stream"; case "$f" in *.zip) ct="application/zip" ;; *.png) ct="image/png" ;; *.jpg|*.jpeg) ct="image/jpeg" ;; esac
      code="$(curl -sS -m 600 -o "$res.resp" -w '%{http_code}' -T "$f" -H "Content-Type: $ct" "$u")"
      echo "upload $p: HTTP $code ($(stat -c %s "$f") bytes)"
      if [ "$code" != 200 ]; then head -c 600 "$res.resp" 2>/dev/null; rm -f "$res.resp"; return 1; fi
      rm -f "$res.resp" ;;
    install)
      # apk path inside the project, or empty = newest builds/android/*.apk; Windows adb, phone on USB with USB debugging on
      local p f adb="$ROOT/tools/platform-tools/adb.exe" win=1
      grep -qi microsoft /proc/version 2>/dev/null || { win=0; adb="$(command -v adb || ls "$HOME/android-sdk/platform-tools/adb" "$ROOT/tools/platform-tools/adb" 2>/dev/null | head -1)"; }
      p="$(printf '%s' "$prompt" | head -1 | tr -d '\r')"
      if [ -z "$p" ]; then f="$(ls -t "$real"/builds/android/*.apk 2>/dev/null | head -1)"; else f="$(realpath -m "$real/$p")"; fi
      [[ -n "$f" && "$f" == "$real"/* && -f "$f" ]] || { echo "REFUSED: no apk found"; return 1; }
      bash "$ROOT/scripts/get-adb.sh" || { echo "adb download failed"; return 1; }
      "$adb" devices
      if [ "$win" = 1 ]; then timeout 300 "$adb" install -r "$(wslpath -w "$f")"; else timeout 300 "$adb" install -r "$f"; fi ;;
    comfy)
      # body line 1: shots file inside the project (default shots.json), optional words: force, only=id,id
      # AI clips and stills on the Windows GPU through ComfyUI (windows\shortcuts\14 Start Video Studio.bat must be open)
      local p f extra=() w2
      p="$(printf '%s' "$prompt" | head -1 | tr -d '\r')"; set -- $p; f="${1:-shots.json}"; shift 2>/dev/null
      for w2 in "$@"; do case "$w2" in force) extra+=(--force) ;; only=*) extra+=(--only "${w2#only=}") ;; esac; done
      f="$(realpath -m "$real/$f")"
      [[ "$f" == "$real"/* && -f "$f" ]] || { echo "REFUSED: shots file not found in the project: $f"; return 1; }
      timeout "${COMFY_MAX_SECONDS:-21600}" python3 "$ROOT/scripts/comfy.py" batch "$f" "${extra[@]}" < /dev/null 2>&1 ;;
    video)
      # body line 1: a vidkit command for this project: build | vo | audio | render [cut ...] | verify | snap <cut>
      # motion-video-producer pipeline (CPU, headless Chromium); output in <project>/build/out/
      local cmd rest
      read -r cmd rest <<< "$(printf '%s' "$prompt" | head -1 | tr -d '\r')"
      case "$cmd" in build|vo|audio|render|verify|snap) ;; *) echo "REFUSED: video job body must start with build, vo, audio, render, verify or snap"; return 1 ;; esac
      timeout "${VIDEO_MAX_SECONDS:-10800}" python3 "$ROOT/skills/motion-video-producer/scripts/vidkit.py" "$cmd" "$real" $rest < /dev/null 2>&1 ;;
    *) echo "unknown worker $w"; return 1 ;;
  esac
}

# A failure that means "this model can't take the job right now", so the next one in the chain should try.
# Matched on the last 40 lines only, and only provider-style messages: a build error such as "module not found" in
# the worker's own work must be reported, not hidden behind another model (and must not bench that model for an hour).
LIMIT_PATTERN='rate.?limit|(http|status|code|error)[^a-z0-9]{0,3}429|quota|usage limit|limit reached|too many requests|unauthori[sz]ed|not logged in|login required|insufficient (credit|balance|funds|quota)|out of credits|billing|command not found|model unavailable|model.{0,40}(not found|not available|not supported|does not exist)|ProviderModelNotFound|overloaded|(http|status|code|error)[^a-z0-9]{0,3}503|service unavailable'
is_limit() { tail -n 40 "$1" | grep -qiE "$LIMIT_PATTERN"; }   # $1 = output file of one try

log_usage() {  # one line per model try in logs/usage-ledger.csv (read by scripts/usage.py). $1 id $2 worker $3 spec $4 code $5 start
  case "$2" in graph|git-commit|android|files|upload|install|comfy|video) return ;; esac   # scripts, no model quota
  local lim=0 spec="$3"; [ "$spec" = opencode ] && spec="opencode:free"
  { [ "$4" -eq 124 ] || [ "$4" -eq 75 ] || { [ "$4" -ne 0 ] && is_limit "$res.try"; }; } && lim=1   # limit or stall
  echo "$(date +%s),$1,$(basename "$real" | tr ',' ' '),$2,$spec,$4,$(( $(date +%s) - $5 )),$lim" >> "$ROOT/logs/usage-ledger.csv"
}

recently_stuck() {  # $1 spec: hit a limit or stalled in the last SKIP_STUCK_MINUTES (default 60; NVIDIA: 5, per-minute limits)
  local s="$1" f="$ROOT/logs/usage-ledger.csv" mins="${SKIP_STUCK_MINUTES:-60}"; [ "$s" = opencode ] && s="opencode:free"
  [[ "$s" == opencode:nv* ]] && mins="${SKIP_STUCK_MINUTES_NVIDIA:-5}"
  [ -f "$f" ] && awk -F, -v s="$s" -v c="$(( $(date +%s) - mins * 60 ))" \
    '$5 == s && $1 >= c && $8 == 1 { hit = 1 } END { exit !hit }' "$f"
}

run_job() {  # runs in the background, one per job
  local id="$1" worker="$2" real="$3" effort="$4" model="$5" gate="$6" base="$7" commit="$8" prompt="$9" lock="${10}" fallback="${11}"
  local res="$OUT/$id" start; start="$(date +%s)"
  cd "$real" || { echo "cannot enter $real" > "$res.out"; finish "$res" 1 "$start" "$lock"; return; }
  local before; before="$(git rev-parse --short HEAD 2>/dev/null)"

  # the chain of tries: the job's own worker first, then fallbacks (job header "fallback:" or config/models.env)
  local chain fbvar="FALLBACK_${worker//-/_}"
  case "$worker" in
    gate)   chain="${model:-$GATE_ENGINES}" ;;
    review) chain="${model:-$REVIEW_ENGINES}" ;;
    graph|git-commit|android|files|upload|install|comfy|video) chain="$worker" ;;
    *)      local first="$worker${model:+:$model}"; [ "$first" = opencode ] && first="opencode:free"   # so GLM is never tried twice
            chain="$first ${fallback:-${!fbvar}}" ;;
  esac
  [ "$fallback" = "none" ] && chain="${chain%% *}"

  local code=1 used="" tried=" " spec w m left
  : > "$res.out"
  left="$(echo $chain | wc -w)"
  for spec in $chain; do
    left=$((left - 1))
    [[ "$tried" == *" $spec "* ]] && continue; tried="$tried$spec "
    if [ "$left" -gt 0 ] && recently_stuck "$spec"; then   # never skips the last one in the chain
      echo "=== skip $spec: hit a limit or stalled in the last ${SKIP_STUCK_MINUTES:-60} min" >> "$res.out"; continue
    fi
    if [ "$worker" = gate ] || [ "$worker" = review ]; then w="$worker"; m="$spec"
    else w="${spec%%:*}"; m=""; [[ "$spec" == *:* ]] && m="${spec#*:}"; fi
    rm -f "$res.last"; echo "=== try: $spec" >> "$res.out"
    local t0; t0="$(date +%s)"
    attempt "$w" "$m" > "$res.try"; code=$?
    # a worker that stopped on a provider limit says so (rules/AGENTS-floor.md, "Limits"): treat it as a limit
    [ "$code" -eq 0 ] && tail -n 40 "$res.try" | grep -qiE '^[^a-z]*blockers?[^:]*:[[:space:]]*(rate limit|quota)' && code=75
    cat "$res.try" >> "$res.out"; used="$spec"
    log_usage "$id" "$worker" "$spec" "$code" "$t0"
    [ "$code" -eq 0 ] && break
    [ "$code" -eq 127 ] || [ "$code" -eq 124 ] || [ "$code" -eq 75 ] || is_limit "$res.try" || break   # 124 = timed out (stalled model)   # 127 = tool not installed   # a real failure: report it, don't hide it behind another model
    echo "=== $spec is out of quota or unavailable; trying the next one" >> "$res.out"
  done
  [ -s "$res.last" ] || tail -n 60 "$res.try" > "$res.last" 2>/dev/null
  rm -f "$res.try"; echo "worker used: $used" >> "$res.last"

  if git rev-parse --git-dir >/dev/null 2>&1; then
    { echo "HEAD before: $before  after: $(git rev-parse --short HEAD)"; git status --short; echo; git diff --stat; } > "$res.git"
    git diff > "$res.diff"
  fi
  finish "$res" "$code" "$start" "$lock"
  python3 "$ROOT/scripts/usage.py" quiet >/dev/null 2>&1   # refresh USAGE.md
  echo "[$(date +%H:%M:%S)] job $id finished (exit $code)"
}

echo "Relay running. Watching $IN (up to $MAX_JOBS jobs at once, one per project folder)"
echo "Leave this window open. Ctrl+C to stop."
while true; do
  date +%s > "$R/heartbeat"   # Claude checks this: older than a minute = relay not running
  for job in "$IN"/*.job; do
    [ -e "$job" ] || continue
    [ "$(jobs -rp | wc -l)" -ge "$MAX_JOBS" ] && break
    sed -i 's/\r$//' "$job"
    id="$(basename "$job" .job)"
    worker="$(field "$job" worker)"; dir="$(field "$job" dir)"
    effort="$(field "$job" effort)"; model="$(field "$job" model)"; gate="$(field "$job" gate)"
    base="$(field "$job" base)"; commit="$(field "$job" commit)"
    fallback="$(field "$job" fallback)"
    real="$(realpath -m "$dir")"

    # safety checks
    if [[ " $WORKERS " != *" $worker "* ]]; then mv "$job" "$DONE/"; refuse "$id" "unknown worker '$worker' (allowed: $WORKERS)"; continue; fi
    if ! allowed_dir "$real" || [ ! -d "$real" ]; then mv "$job" "$DONE/"; refuse "$id" "dir must be an existing project folder inside $ALLOWED_ROOT or a folder listed in config/folders.env (not inside Hivemind)"; continue; fi
    if [ "$worker" = "gate" ] && [ ! -f "$ROOT/gates/$gate.md" ]; then mv "$job" "$DONE/"; refuse "$id" "gate must be build, security or release"; continue; fi
    case "$effort" in ""|none|low|medium|high|xhigh|max) ;; *) effort="medium" ;; esac
    [[ "$base$commit$model$fallback" =~ ^[A-Za-z0-9._/:\ -]*$ ]] || { mv "$job" "$DONE/"; refuse "$id" "bad base, commit, model or fallback"; continue; }

    lock="$LOCKS/$(printf '%s' "$real" | md5sum | cut -c1-12)"
    mkdir "$lock" 2>/dev/null || continue   # that folder is busy: the job waits for the next round
    prompt="$(body "$job")"
    mv "$job" "$DONE/$id.job"
    rm -f "$OUT/$id".*
    echo "[$(date +%H:%M:%S)] job $id: $worker in $dir" | tee "$OUT/$id.running"; status_board
    load_config
    run_job "$id" "$worker" "$real" "$effort" "$model" "$gate" "$base" "$commit" "$prompt" "$lock" "$fallback" &
  done
  sleep 5
done
