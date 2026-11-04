#!/usr/bin/env bash
# Keeps a Mac or Linux computer awake while Hivemind works, then lets it sleep again. No window: started in the
# background by Start Hivemind and shortcuts/1 Start Relay. Settings: config/awake.env.
# Awake = relay running AND (a job queued or running, autopilot running, or the last job ended less than
# AWAKE_GRACE_MINUTES ago). macOS: caffeinate. Linux: systemd-inhibit (no systemd: nothing is held, said once).
# Stops by itself 10 minutes after the relay closes. State for the usage view: relay/awake.state (on / off).
cd "$(dirname "$0")/.." || exit 1
R=relay; PIDF="$R/.keep-awake.pid"
[ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null && exit 0   # one copy only
echo $$ > "$PIDF"
hold=""; on=""; down=""
release() { [ -n "$hold" ] && kill "$hold" 2>/dev/null; hold=""; }
trap 'release; echo off > "$R/awake.state"; rm -f "$PIDF"; exit 0' INT TERM EXIT
num() { local v; v="$(tr -dc 0-9 < "$R/$1" 2>/dev/null)"; echo "${v:-0}"; }
while :; do
  KEEP_AWAKE=yes; AWAKE_GRACE_MINUTES=15; AWAKE_DISPLAY=no
  [ -f config/awake.env ] && . config/awake.env
  now=$(date +%s); up=0; [ $(( now - $(num heartbeat) )) -lt 120 ] && up=1
  busy=0; [ "$up" = 1 ] && [ "$KEEP_AWAKE" = yes ] && [ $(( now - $(num activity) )) -lt $(( AWAKE_GRACE_MINUTES * 60 )) ] && busy=1
  if [ "$busy" = 1 ] && { [ -z "$hold" ] || ! kill -0 "$hold" 2>/dev/null; }; then
    if [ "$(uname -s)" = Darwin ]; then
      if [ "$AWAKE_DISPLAY" = yes ]; then caffeinate -i -d & else caffeinate -i & fi; hold=$!
    elif command -v systemd-inhibit >/dev/null; then
      what="idle:sleep"; systemd-inhibit --what="$what" --who=Hivemind --why="relay jobs running" sleep infinity & hold=$!
    else [ -z "$warned" ] && echo "keep-awake: no systemd-inhibit here; the computer may sleep" >&2; warned=1; fi
  elif [ "$busy" = 0 ]; then release; fi
  [ "$busy" != "$on" ] && { on="$busy"; [ "$busy" = 1 ] && echo on > "$R/awake.state" || echo off > "$R/awake.state"; }
  if [ "$up" = 1 ]; then down=""; elif [ -z "$down" ]; then down=$now; elif [ $(( now - down )) -gt 600 ]; then break; fi
  sleep 30
done
