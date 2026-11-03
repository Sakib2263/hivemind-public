#!/usr/bin/env bash
# Starts or prepares a game project and records the answers in project.yaml, which every later step reads
# (which playbook, SDKs, builds, QA, release). Started by "windows\shortcuts\8 New Project.bat".
# Never overwrites an existing file. Can rename the game and the folder of an existing project or reskin.
KIT="$(cd "$(dirname "$0")/.." && pwd)"; WORK="$(dirname "$KIT")"
pick() {  # $1 question, rest = options -> REPLY
  local q="$1"; shift; local i=1 o n
  echo; echo "$q"; for o in "$@"; do echo "  $i = $o"; i=$((i+1)); done
  while :; do read -r -p "Choose 1-$#: " n || exit 1; [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le $# ] && { REPLY="${!n}"; return; }; done
}
multi() {  # $1 question, rest = options -> REPLY = "a, b"
  local q="$1"; shift; local i=1 o n out=""
  echo; echo "$q (type the numbers, separated by spaces)"; for o in "$@"; do echo "  $i = $o"; i=$((i+1)); done
  while :; do read -r -p "Numbers: " line || exit 1; out=""
    for n in $line; do [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le $# ] && out="$out, ${!n%% (*}"; done
    [ -n "$out" ] && { REPLY="${out#, }"; return; }; done
}
topath() { local p="${1//\"/}"; [[ "$p" =~ ^[A-Za-z]: ]] && p="$(wslpath -u "$p")"; echo "${p%/}"; }
yget() {  # value of a top-level key in a simple yaml file: quoted text, or the word before a comment
  local v; v="$(sed -n "s/^$1: *//p" "$2" 2>/dev/null | head -1 | tr -d '\r')"
  if [[ "$v" == \"* ]]; then v="${v#\"}"; v="${v%%\"*}"; else v="${v%%#*}"; v="${v%"${v##*[! ]}"}"; fi
  echo "$v"
}

pick "What are we starting?" "new (empty project)" "existing (a project that already exists)" "reskin (copy a base game: new name, look and tuning)"
START="${REPLY%% *}"; SRC=""; DEST=""
case "$START" in
  existing) read -r -p "Project folder (drag it here or paste the path): " D; DEST="$(topath "$D")"
            [ -d "$DEST" ] || { echo "Folder not found: $DEST"; exit 1; }
            read -r -p "Rename the folder? New name, or Enter to keep [$(basename "$DEST")]: " FOLDER; FOLDER="${FOLDER:-$(basename "$DEST")}" ;;
  reskin)   read -r -p "Base game folder to copy (drag it here or paste the path): " D; SRC="$(topath "$D")"
            [ -d "$SRC" ] || { echo "Folder not found: $SRC"; exit 1; }
            read -r -p "Folder name for the copy (a working name; the game title is decided before release): " FOLDER
            [ -n "$FOLDER" ] || { echo "No folder name given."; exit 1; } ;;
  *)        read -r -p "Folder name (a working name; the game title is decided before release): " FOLDER
            [ -n "$FOLDER" ] || { echo "No folder name given."; exit 1; } ;;
esac

BASE="${SRC:-$DEST}"
if [ -n "$BASE" ] && [ -f "$BASE/ProjectSettings/ProjectVersion.txt" ]; then
  ENGINE=unity; echo; echo "Engine: Unity (found in the project)"
else
  pick "Engine?" "web (three.js, Canvas, Vite: one codebase for web, Android and iOS)" "unity"; ENGINE="${REPLY%% *}"
fi

multi "Target platforms?" "android" "ios (later)" "web"; TARGETS="$REPLY"
ANDROID_DIST=""; MOBILE_SDKS=""; PUBLISHER=""; WEB_WHERE=""
if [[ "$TARGETS" == *android* ]]; then
  multi "Android: where will it go?" "google-play" "third-party-stores (Samsung, Xiaomi, Huawei, Amazon...)" "test-apk (only for testing)"; ANDROID_DIST="$REPLY"
fi
if [[ "$TARGETS" == *android* || "$TARGETS" == *ios* ]]; then
  pick "Mobile SDKs (ads, analytics, IAP)?" "own (only our SDKs)" "publisher (the publisher's SDK)"; MOBILE_SDKS="${REPLY%% *}"
  if [ "$MOBILE_SDKS" = publisher ]; then
    pick "Which publisher?" voodoo supersonic homa other; PUBLISHER="$REPLY"
    [ "$PUBLISHER" = other ] && { read -r -p "Publisher name: " PUBLISHER; PUBLISHER="$(echo "$PUBLISHER" | tr 'A-Z ' 'a-z-')"; }
  fi
fi
if [[ "$TARGETS" == *web* ]]; then
  multi "Web: where will it go?" "playgama" "poki" "crazygames" "own-website" "other"; WEB_WHERE="$REPLY"
fi
pick "Size (tier)?" "S prototype / mechanic test" "M small scalable game" "L depth game"; TIER="${REPLY%% *}"

if [ "$ENGINE" = web ] && [ -n "$PUBLISHER" ]; then
  echo; echo "Note: $PUBLISHER test builds usually need Unity and their SDK. Check their current requirements first."
fi

PARENT="$WORK"
if [ "$START" != existing ]; then
  read -r -p "Create it where? Enter = the work folder [$WORK], or paste another folder: " D
  [ -n "$D" ] && PARENT="$(topath "$D")"
  [ -d "$PARENT" ] || { echo "Folder not found: $PARENT"; exit 1; }
fi
case "$START" in existing) NEWDEST="$(dirname "$DEST")/$FOLDER" ;; *) NEWDEST="$PARENT/$FOLDER" ;; esac
case "$NEWDEST" in "$KIT"|"$KIT"/*) echo "Projects can't live inside the Hivemind folder. Choose another place."; exit 1 ;; esac
echo; echo "Folder: $NEWDEST | $START${SRC:+ of $SRC} | engine: $ENGINE | tier: $TIER"
echo "Targets: $TARGETS${ANDROID_DIST:+ | android: $ANDROID_DIST}${MOBILE_SDKS:+ | mobile SDKs: $MOBILE_SDKS${PUBLISHER:+ ($PUBLISHER)}}${WEB_WHERE:+ | web: $WEB_WHERE}"
read -r -p "Go ahead? (Y/n): " a; [[ "$a" =~ ^[Nn] ]] && { echo "Stopped."; exit 0; }

case "$START" in
  existing)
    if [ "$NEWDEST" != "$DEST" ]; then
      [ -e "$NEWDEST" ] && { echo "A folder named $FOLDER already exists there."; exit 1; }
      mv "$DEST" "$NEWDEST" 2>/dev/null || { echo "Could not rename the folder: close any program using it (editor, Explorer, relay) and run this again."; exit 1; }
      echo "Folder renamed to $FOLDER"
    fi ;;
  reskin)
    [ -e "$NEWDEST" ] && { echo "Already exists: $NEWDEST"; exit 1; }
    mkdir -p "$NEWDEST"
    ex=(); for e in .git node_modules Library Temp Obj Logs UserSettings Build Builds builds graphify-out android.env project.yaml TASKS.md PLAN.md; do ex+=(--exclude="./$e"); done
    tar -C "$SRC" "${ex[@]}" -cf - . | tar -C "$NEWDEST" -xf - || { echo "Copy failed."; exit 1; } ;;
  *)
    [ -e "$NEWDEST" ] && { echo "Already exists: $NEWDEST (choose 'existing')"; exit 1; }
    mkdir -p "$NEWDEST" ;;
esac
cd "$NEWDEST" || exit 1
# outside the work folder? list its parent in config/folders.env so the relay may work there
P_UP="$(dirname "$NEWDEST")"
if [[ "$NEWDEST" != "$WORK"/* ]] && ! grep -qF "$P_UP" "$KIT/config/folders.env" 2>/dev/null; then
  cur="$(sed -n 's/^WORK_FOLDERS="\(.*\)"/\1/p' "$KIT/config/folders.env" 2>/dev/null)"
  new="${cur:+$cur;}$P_UP"
  if [ -f "$KIT/config/folders.env" ]; then sed -i "s#^WORK_FOLDERS=.*#WORK_FOLDERS=\"$new\"#" "$KIT/config/folders.env"
  else printf 'WORK_FOLDERS="%s"\n' "$new" > "$KIT/config/folders.env"; fi
  echo "Added $P_UP to config/folders.env, so the relay can work there. Also add this folder in Claude (+ > Add folder)."
fi

UV=""; [ -f ProjectSettings/ProjectVersion.txt ] && UV="$(sed -n 's/^m_EditorVersion: //p' ProjectSettings/ProjectVersion.txt | tr -d '\r')"
TITLE="$(yget store_title project.yaml)"
if [ -f project.yaml ]; then mv project.yaml project.yaml.old; echo "Old project.yaml kept as project.yaml.old"; fi
{
  echo "# Project profile (Hivemind). Every step reads it: playbook, SDKs, builds, QA, release."
  echo "folder: \"$FOLDER\"           # working name; rename any time with this .bat"
  echo "store_title: \"$TITLE\"           # decided before the first release, with ASO (google-play-release skill)"
  echo "start: $START"
  echo "reskin_of: \"$SRC\""
  echo "engine: $ENGINE                # web = three.js / Canvas / Vite; unity"
  echo "targets: [$TARGETS]"
  [ -n "$ANDROID_DIST" ] && echo "android: { distribution: [$ANDROID_DIST] }"
  [[ "$TARGETS" == *ios* ]] && echo "ios: { status: later }"
  [ -n "$MOBILE_SDKS" ] && echo "mobile_sdks: { source: $MOBILE_SDKS, publisher: \"$PUBLISHER\" }"
  [ -n "$WEB_WHERE" ] && echo "web: { where: [$WEB_WHERE] }"
  echo "tier: $TIER"
  echo "unity_version: \"$UV\""
  echo "playbook: stacks/$ENGINE.md"
  echo "notes: \"\""
} > project.yaml
for f in CLAUDE.md AGENTS.md PLAN.md TASKS.md; do [ -f "$f" ] || cp "$KIT/templates/$f" .; done
if [[ "$TARGETS" == *android* ]] && [ "$ENGINE" = web ] && [ ! -f android.env ]; then
  printf '# Name and bundle id are decided before the first release; test builds use stand-ins.\nAPP_NAME=""\nAPP_ID=""\nICON=""\nORIENTATION="portrait"\nVERSION_NAME="1.0.0"\nVERSION_CODE=1\n' > android.env
fi
if [ ! -f .gitignore ]; then
  if [ "$ENGINE" = unity ]; then
    printf '%s\n' '[Ll]ibrary/' '[Tt]emp/' '[Oo]bj/' '[Bb]uild/' '[Bb]uilds/' '[Ll]ogs/' '[Uu]ser[Ss]ettings/' \
      '[Mm]emoryCaptures/' '*.csproj' '*.sln' '*.apk' '*.aab' '*.keystore' 'graphify-out/' > .gitignore
    [ -f .gitattributes ] || printf '%s\n' '* text=auto' '*.unity merge=unityyamlmerge eol=lf' '*.prefab merge=unityyamlmerge eol=lf' \
      '*.asset merge=unityyamlmerge eol=lf' '*.png filter=lfs diff=lfs merge=lfs -text' '*.psd filter=lfs diff=lfs merge=lfs -text' \
      '*.wav filter=lfs diff=lfs merge=lfs -text' '*.mp3 filter=lfs diff=lfs merge=lfs -text' '*.fbx filter=lfs diff=lfs merge=lfs -text' > .gitattributes
  else
    printf '%s\n' 'node_modules/' 'dist/' 'builds/' 'graphify-out/' '*.keystore' > .gitignore
  fi
fi
if [ ! -d .git ]; then git init -q && git add -A && git -c user.name=hivemind -c user.email=hivemind@local commit -qm "project start ($ENGINE, $START)" && echo "git ready"; fi

echo; echo "Ready: $NEWDEST"
echo "Playbook: Hivemind\\stacks\\$ENGINE.md"
if [ "$START" = reskin ]; then
  if [ "$ENGINE" = unity ]; then echo "Reskin: before its first release it needs a NEW bundle id, name and icon in Player Settings (Claude can do it through Unity MCP)."
  else echo "Reskin: name and bundle id start empty; they are decided (NEW bundle id) before its first release."; fi
fi
if [ "$ENGINE" = unity ] && [ ! -f ProjectSettings/ProjectVersion.txt ]; then
  echo "Next: create the Unity project in Unity Hub INSIDE this folder, then ask Claude to set it up from stacks/unity.md."
else
  echo "Next: in Claude, say: Read project.yaml in <this folder> and plan: <what you want>."
fi
