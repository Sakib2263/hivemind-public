#!/usr/bin/env bash
# Progress helper for every setup and check script: a window must never look stuck.
#   . "$KIT/scripts/progress.sh"
#   busy "label" command args...   runs the command with a live spinner and timer on screen
#                                  ("  / label ... 12s"), then clears it. Returns the command's exit code.
#                                  Its output is in $BUSY_OUT (a file); $BUSY_SECS = seconds taken.
# The spinner goes to the screen only (never into logs). Not for commands that ask for input.
_busy_tty() { if [ -t 1 ]; then echo /dev/stdout; elif { : >/dev/tty; } 2>/dev/null; then echo /dev/tty; fi; }
busy() {
  local label="$1"; shift
  local t0=$SECONDS tty s='|/-\' i=0 pid rc
  BUSY_OUT="$(mktemp)"; tty="$(_busy_tty)"
  [ -n "$tty" ] || echo "  $label ..."
  "$@" > "$BUSY_OUT" 2>&1 < /dev/null & pid=$!
  if [ -n "$tty" ]; then
    sleep 0.5   # quick commands finish without a spinner; lets earlier log lines reach the screen first
    while kill -0 "$pid" 2>/dev/null; do
      printf '\r  %s %s ... %ss ' "${s:$((i++ % 4)):1}" "$label" $((SECONDS - t0)) > "$tty"; sleep 0.25
    done
    [ "$i" -gt 0 ] && printf '\r\033[K' > "$tty"
  fi
  wait "$pid"; rc=$?; BUSY_SECS=$((SECONDS - t0))
  return $rc
}
