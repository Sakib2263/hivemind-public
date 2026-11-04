#!/usr/bin/env bash
# Project memory with graphify: a map of the code (graphify-out/GRAPH_REPORT.md + graph.json) so a new chat reads
# one short report instead of the whole codebase. Code only (tree-sitter): no AI model, no tokens.
#   bash graph.sh <project dir> ensure        build if missing, refresh if older than the last commit (relay: every job)
#   bash graph.sh <project dir> update        rebuild now ("graph" job body "update" or "build")
#   bash graph.sh <project dir> "<question>"  ask the graph: plain question, or "explain <name>", "path <A> <B>",
#                                             "affected <name>", "hubs"
# Also installs graphify's git hooks once per project, so every commit refreshes the map by itself.
DIR="${1:-.}"; shift; ACT="${*:-ensure}"
cd "$DIR" 2>/dev/null || { echo "graph: folder not found: $DIR"; exit 1; }
export PATH="$HOME/.local/bin:$PATH"
command -v graphify >/dev/null || { echo "graph: graphify not installed (2 Install AI Tools)"; exit 127; }
# clean environment: graphify then builds the code-only map and never calls a paid model for extra summaries
G() { env -i HOME="$HOME" PATH="$PATH" LANG=C.UTF-8 PYTHONHASHSEED=0 graphify "$@"; }
REPORT=graphify-out/GRAPH_REPORT.md
hooks() { git rev-parse --git-dir >/dev/null 2>&1 && ! G hook status 2>/dev/null | grep -q "post-commit: installed" && G hook install >/dev/null 2>&1; }
build() {
  # Unity: only the game's own code (Library/, Temp/ etc. would explode time and size)
  [ -d Assets ] && [ -d ProjectSettings ] && [ ! -f .graphifyignore ] && printf '%s\n' Library/ Temp/ Obj/ Logs/ UserSettings/ Build/ Builds/ builds/ > .graphifyignore
  G update . 2>&1 | tail -2
  [ -f "$REPORT" ] || G cluster-only . --no-label --no-viz 2>&1 | tail -1
  [ -f .gitignore ] && ! grep -qs '^graphify-out/' .gitignore && echo 'graphify-out/' >> .gitignore
  hooks
  if [ -f "$REPORT" ]; then echo "graph: $REPORT ready ($(grep -m1 -oE '[0-9]+ nodes' "$REPORT"))"; else echo "graph: build failed"; return 1; fi
}
case "$ACT" in
  ensure)
    git rev-parse --git-dir >/dev/null 2>&1 || [ -f "$REPORT" ] || exit 0   # not a code project: nothing to map
    head="$(git rev-parse --short=8 HEAD 2>/dev/null)"
    if [ ! -f "$REPORT" ]; then build
    elif [ -n "$head" ] && ! grep -q "commit: \`$head" "$REPORT"; then build
    else hooks; echo "graph: current"; fi ;;
  update|build) build ;;
  hubs) G god-nodes ;;
  explain\ *|path\ *|affected\ *) set -- $ACT; cmd="$1"; shift; G "$cmd" "$@" ;;
  *) [ -f "$REPORT" ] || build >/dev/null; G query "$ACT" ;;
esac
