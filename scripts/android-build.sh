#!/usr/bin/env bash
# Builds an Android app from a web game project (single HTML file, or a Node/Vite project) with Capacitor.
#   android-build.sh <project folder> debug     -> test APK (install on a phone)
#   android-build.sh <project folder> release   -> signed AAB for Google Play + signed APK
# App facts live in <project>/android.env (no secrets). Missing facts: asked when run by a person,
# listed as "MISSING:" (exit 3) when run by the relay, so Claude can ask the owner.
# Signing: one keystore for all apps, set once per PC in the kit's secrets/android/signing.env (never committed).
# New users are asked for it (studio, bundle start, keystore, alias, password) before the bundle id.
# Unity projects are built through Unity (plans/UNITY-PLAN.md), not here.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$HOME/.local/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null
P="$(realpath "${1:-.}")"; MODE="${2:-debug}"
die() { echo "FAIL: $*"; exit 1; }
missing() { echo "MISSING: $*"; exit 3; }
TTY=0; [ -t 0 ] && TTY=1

case "$MODE" in debug|release) ;; *) die "build type must be debug or release" ;; esac
[ -d "$P" ] || die "project folder not found: $P"
[ -f "$P/ProjectSettings/ProjectVersion.txt" ] && die "this is a Unity project: build it from Unity (see plans/UNITY-PLAN.md)"
command -v javac >/dev/null && [ -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ] \
  || die "Android build tools are not installed: run '6 Optional - Android Build Tools.bat' first"
command -v npx >/dev/null || die "Node is missing: run '2 Install AI Tools.bat'"

# ---- 1. Signing setup (once per PC) -------------------------------------------------------------
SD="$KIT/secrets/android"; SIGNF="$SD/signing.env"; mkdir -p "$SD"
[ -f "$SIGNF" ] && . <(tr -d '\r' < "$SIGNF")
setup_signing() {
  echo "== Signing setup (once per PC). Used for every release build, and for signed Unity builds."
  local org low pw pw2
  read -r -p "Studio or company name [My Studio]: " org; ORG_NAME="${org:-My Studio}"
  low="$(echo "$ORG_NAME" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9')"
  read -r -p "Bundle id start, like com.yourstudio [com.$low]: " BUNDLE_PREFIX; BUNDLE_PREFIX="${BUNDLE_PREFIX:-com.$low}"
  read -r -p "Keystore: a file name to create, or the full path of one you already use [$low.keystore]: " KEYSTORE; KEYSTORE="${KEYSTORE:-$low.keystore}"
  read -r -p "Key alias [$low]: " KEY_ALIAS; KEY_ALIAS="${KEY_ALIAS:-$low}"
  read -r -s -p "Keystore password (6+ characters): " pw; echo
  read -r -s -p "Type it again: " pw2; echo
  [ "$pw" = "$pw2" ] && [ "${#pw}" -ge 6 ] || die "passwords don't match or are too short"
  STORE_PASS="$pw"; KEY_PASS="$pw"
  printf '# Release signing for every app built on this PC. Private: never commit or share.\nORG_NAME="%s"\nBUNDLE_PREFIX="%s"\nKEYSTORE="%s"\nKEY_ALIAS="%s"\nSTORE_PASS="%s"\nKEY_PASS="%s"\n' \
    "$ORG_NAME" "$BUNDLE_PREFIX" "$KEYSTORE" "$KEY_ALIAS" "$STORE_PASS" "$KEY_PASS" > "$SIGNF"
  chmod 600 "$SIGNF"; echo "Saved: secrets/android/signing.env"
  local ks="$KEYSTORE"; [[ "$ks" == /* ]] || ks="$SD/$ks"
  [ -f "$ks" ] || { touch "$SD/ALLOW_NEW_KEY"; echo "A new keystore will be made on this first release build."; }
}
if [ "$MODE" = release ] && [ ! -f "$SIGNF" ]; then
  [ "$TTY" = 1 ] && setup_signing || missing "signing setup. Run windows\shortcuts\\10 Build Android App.bat once and choose release (it asks for the keystore details)"
fi

# ---- 2. App facts ----------------------------------------------------------------------------
ENVF="$P/android.env"; [ -f "$ENVF" ] && . <(tr -d '\r' < "$ENVF")
SLUG="$(basename "$P" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9')"
ID_RE='^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$'
ask() {  # $1 var  $2 question  $3 suggestion
  local cur="${!1}"; [ -n "$cur" ] && return
  if [ "$TTY" = 1 ]; then read -r -p "$2 [$3]: " cur; printf -v "$1" '%s' "${cur:-$3}"; fi
}
S_NAME="$APP_NAME"; S_ID="$APP_ID"   # what is saved in android.env (decided names only)
if [ "$MODE" = debug ]; then
  # Test builds ask nothing: the name and bundle id are decided before the first release (with ASO),
  # so a test APK uses stand-ins that are NOT saved.
  APP_NAME="${APP_NAME:-$(basename "$P")}"; APP_NAME="${APP_NAME:0:30}"
  APP_ID="${APP_ID:-${BUNDLE_PREFIX:-com.yourstudio}.$SLUG.test}"
  ORIENTATION="${ORIENTATION:-portrait}"
else
  [ "$TTY" = 1 ] && [ -z "$S_NAME$S_ID" ] && echo "First release: decide the app name and bundle id now (store title and ASO: google-play-release skill)."
  ask APP_NAME "App name under the icon (max 30 characters; the store title can still differ)" "$(basename "$P")"
  ask APP_ID "Bundle id / package name (can NEVER change after the first Play upload)" "${BUNDLE_PREFIX:-com.yourstudio}.$SLUG"
  ask ICON "App icon: path to a square PNG, 1024x1024, inside the project" ""
  ask ORIENTATION "Screen orientation: portrait, landscape or any" "portrait"
  S_NAME="$APP_NAME"; S_ID="$APP_ID"
fi
VERSION_NAME="${VERSION_NAME:-1.0.0}"; VERSION_CODE="${VERSION_CODE:-1}"

NEED=""
[ -z "$APP_NAME" ] && NEED="$NEED APP_NAME"
[ -z "$APP_ID" ] && NEED="$NEED APP_ID"
[ "$MODE" = release ] && [ -z "$ICON" ] && NEED="$NEED ICON(required for release)"
[ -n "$NEED" ] && missing "$NEED. Ask the owner (decide the name with ASO), put them in $ENVF, or run windows\shortcuts\\10 Build Android App.bat"
[[ "$APP_ID" =~ $ID_RE ]] || die "bundle id '$APP_ID' is not valid: lowercase words joined by dots, like com.yourstudio.mygame"
[ "${#APP_NAME}" -le 30 ] || die "app name is longer than 30 characters"
if [ -n "$ICON" ]; then
  [ -f "$P/$ICON" ] || [ -f "$ICON" ] || die "icon not found: $ICON"
  IC="$P/$ICON"; [ -f "$IC" ] || IC="$ICON"
  python3 "$KIT/scripts/check-store-assets.py" --icon "$IC" >/tmp/hm-icon.txt 2>&1 \
    || { cat /tmp/hm-icon.txt; [ "$MODE" = release ] && die "the icon must be a square PNG, at least 512px (best 1024x1024)"; echo "WARNING: icon not right; test build continues"; }
fi

echo "App:         $APP_NAME$( [ -z "$S_NAME" ] && echo '  (test stand-in, not saved)')"
echo "Bundle id:   $APP_ID$( [ -z "$S_ID" ] && echo '  (test stand-in, not saved)')"
echo "Icon:        ${ICON:-(none: default icon)}"
echo "Version:     $VERSION_NAME ($VERSION_CODE)   Orientation: ${ORIENTATION:-any}   Build: $MODE"
if [ "$TTY" = 1 ]; then read -r -p "Build with these? (Y/n): " a; [[ "$a" =~ ^[Nn] ]] && { echo "Stopped. Edit $ENVF and run again."; exit 0; }; fi
cat > "$ENVF" <<ENV
# Android app facts for Hivemind builds (no secrets here). Empty name or bundle id = not decided yet
# (test builds use stand-ins; the first release asks). Bundle id can never change after the first Play upload.
APP_NAME="$S_NAME"
APP_ID="$S_ID"
ICON="$ICON"
ORIENTATION="$ORIENTATION"
SPLASH_COLOR="$SPLASH_COLOR"
VERSION_NAME="$VERSION_NAME"
VERSION_CODE=$VERSION_CODE
ENV
[ -n "$WEB_ENTRY" ] && echo "WEB_ENTRY=\"$WEB_ENTRY\"" >> "$ENVF"   # keep the per-target entry
[ -n "$WEB_DIR" ] && echo "WEB_DIR=\"$WEB_DIR\"" >> "$ENVF"

# ---- 3. Web files ------------------------------------------------------------------------------
W="$HOME/hivemind-builds/$APP_ID"   # build in Linux, not on D: (much faster for npm and Gradle)
mkdir -p "$W/www"
if [ -f "$P/package.json" ] && grep -q '"build"' "$P/package.json"; then
  echo "== npm build"; (cd "$P" && npm install --no-audit --no-fund && npm run build) || die "the web build failed"
  SRC="$P/${WEB_DIR:-dist}"
else
  SRC="$P"
fi
rsync -a --delete --exclude .git --exclude node_modules --exclude builds --exclude graphify-out --exclude store \
  --exclude '*.md' --exclude android.env --exclude .android --exclude native-android --exclude google-services.json \
  --exclude releases --exclude tools --exclude tests --exclude prototype --exclude _src-audio "$SRC/" "$W/www/"
if [ -n "$WEB_ENTRY" ] && [ "$WEB_ENTRY" != "index.html" ]; then
  # per-target entry (index.android.html): it becomes index.html; other targets' entries stay out of the app
  [ -f "$W/www/$WEB_ENTRY" ] || die "WEB_ENTRY $WEB_ENTRY not found in $SRC"
  mv -f "$W/www/$WEB_ENTRY" "$W/www/index.html"
  rm -f "$W/www"/index.*.html
elif [ ! -f "$W/www/index.html" ]; then
  ENTRY="$(cd "$W/www" && ls *.html 2>/dev/null | head -1)"
  [ -n "$ENTRY" ] || die "no .html file found in $SRC"
  mv "$W/www/$ENTRY" "$W/www/index.html"
fi

# ---- 4. Android project (Capacitor) ---------------------------------------------------------------
cd "$W" || die "cannot open $W"
if [ ! -f package.json ]; then
  echo "== first build of this app: setting up Capacitor (a few minutes)"
  npm init -y >/dev/null && npm install --no-audit --no-fund @capacitor/core @capacitor/cli @capacitor/android \
    && npm install --no-audit --no-fund -D @capacitor/assets || die "npm install failed"
fi
# Firebase: Capacitor applies the google-services plugin when android/app/google-services.json exists
if [ -f "$P/google-services.json" ]; then
  grep -q "\"$APP_ID\"" "$P/google-services.json" || die "google-services.json has no client for $APP_ID"
  cp "$P/google-services.json" android/app/google-services.json
fi
if [ -n "$SPLASH_COLOR" ]; then
  printf '{ "appId": "%s", "appName": "%s", "webDir": "www", "backgroundColor": "%s" }\n' "$APP_ID" "$APP_NAME" "$SPLASH_COLOR" > capacitor.config.json
else
  printf '{ "appId": "%s", "appName": "%s", "webDir": "www" }\n' "$APP_ID" "$APP_NAME" > capacitor.config.json
fi
[ -d android ] || npx cap add android || die "could not create the Android project"
npx cap sync android >/dev/null || die "cap sync failed"
G=android/app/build.gradle
sed -i -E "s/applicationId \"[^\"]*\"/applicationId \"$APP_ID\"/; s/versionCode [0-9]+/versionCode $VERSION_CODE/; s/versionName \"[^\"]*\"/versionName \"$VERSION_NAME\"/" "$G"
S=android/app/src/main/res/values/strings.xml
sed -i -E "s#(<string name=\"(app_name|title_activity_main)\">)[^<]*#\1${APP_NAME//&/\\&}#" "$S"
M=android/app/src/main/AndroidManifest.xml
sed -i -E 's/ android:screenOrientation="[a-z]*"//' "$M"
[ -n "$ORIENTATION" ] && [ "$ORIENTATION" != any ] && sed -i -E "0,/<activity/s//<activity android:screenOrientation=\"$ORIENTATION\"/" "$M"
RES=android/app/src/main/res
if [ -n "$ICON" ]; then
  # Own icon maker: all densities + the adaptive icon (Android 8+). @capacitor/assets left the adaptive
  # foreground on Capacitor's default logo without any error, so it is not used any more.
  I="$P/$ICON"; [ -f "$I" ] || I="$ICON"
  rm -f "$RES"/drawable*/ic_launcher_background.* "$RES"/drawable*/ic_launcher_foreground.*
  node "$KIT/scripts/make-android-icon.cjs" make "$I" "$RES" || die "icon generation failed ($ICON)"
fi

# ---- 4b. Optional project native code: <project>/native-android/ -----------------------------------
#   app/...                  copied into android/app/ (Java sources, res)
#   java/*.java              copied to android/app/src/main/java/<package path> (keeps Windows paths short)
#   app.gradle               applied at the end of android/app/build.gradle (repos, deps, minSdk)
#   manifest-application.xml inserted before </application>
#   MainActivity.java        replaces the generated MainActivity (package line kept)
#   ads.example.env          used when secrets/android/<APP_ID>.ads.env is missing (test placeholders)
# Every KEY=value in the ads env becomes a string resource "hm_<key lowercase>".
# SPLASH_COLOR (android.env) sets the launch screen and web view background color.
NA="$P/native-android"
if [ -d "$NA" ]; then
  echo "== adding native code from native-android/"
  [ -d "$NA/app" ] && rsync -a "$NA/app/" android/app/
  for J in "$NA"/java/*.java; do                       # flat java/ folder: placed by each file's package line
    [ -f "$J" ] || continue
    PK="$(tr -d '\r' < "$J" | grep -m1 -oE '^package [A-Za-z0-9_.]+' | cut -d' ' -f2)"; [ -n "$PK" ] || die "no package line in $J"
    mkdir -p "android/app/src/main/java/${PK//.//}" && cp "$J" "android/app/src/main/java/${PK//.//}/"
  done
  if [ -f "$NA/app.gradle" ]; then
    cp "$NA/app.gradle" android/app/hm-native.gradle
    grep -q "hm-native.gradle" "$G" || printf "\napply from: 'hm-native.gradle'\n" >> "$G"
  fi
  if [ -f "$NA/manifest-application.xml" ]; then
    python3 - "$M" "$NA/manifest-application.xml" <<'PY' || die "could not add native-android/manifest-application.xml"
import sys; m, add = sys.argv[1], open(sys.argv[2]).read()
s = open(m).read()
if "<!-- hm-native -->" in s: s = s[:s.index("<!-- hm-native -->")] + s[s.rindex("</application>"):]  # replace the old block every build
i = s.rindex("</application>")
open(m, "w").write(s[:i] + "<!-- hm-native -->\n" + add + "\n" + s[i:])
PY
  fi
  if [ -f "$NA/MainActivity.java" ]; then
    MA="$(find android/app/src/main/java -name MainActivity.java | head -1)"; [ -n "$MA" ] || die "generated MainActivity.java not found"
    { grep -m1 '^package ' "$MA"; grep -v '^package ' "$NA/MainActivity.java"; } > "$MA.new" && mv "$MA.new" "$MA"
  fi
  ADS="$SD/$APP_ID.ads.env"; [ -f "$ADS" ] || ADS="$NA/ads.example.env"
  if [ -f "$ADS" ]; then
    [ "$ADS" = "$NA/ads.example.env" ] && echo "NOTE: ads use test placeholders (no secrets/android/$APP_ID.ads.env)"
    if [ "$MODE" = release ] && grep -qiE '=(|none|test.*|.*3940256099942544.*)[[:space:]]*$' <(tr -d '\r"' < "$ADS"); then
      die "ads settings still have test or empty values in $(basename "$ADS"). Put the real IDs in secrets/android/$APP_ID.ads.env"
    fi
    python3 - "$ADS" android/app/src/main/res/values/hm_ads.xml <<'PY' || die "could not read the ads settings"
import sys, html
out = ['<?xml version="1.0" encoding="utf-8"?>', '<resources>']
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    if not line or line.startswith("#") or "=" not in line: continue
    k, v = line.split("=", 1)
    out.append('    <string name="hm_%s" translatable="false">%s</string>' % (k.strip().lower(), html.escape(v.strip().strip('"'))))
out.append('</resources>')
open(sys.argv[2], "w").write("\n".join(out) + "\n")
PY
  fi
fi
if [ -n "$SPLASH_COLOR" ]; then
  printf '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="hm_splash">%s</color>\n</resources>\n' "$SPLASH_COLOR" > android/app/src/main/res/values/hm_splash.xml
  sed -i 's#@drawable/splash#@color/hm_splash#g' android/app/src/main/res/values/styles.xml
fi

# ---- 4c. Web checks: More Games offered => module shipped ------------------------------------------
if grep -q 'moreGamesSupported: *true' www/index.html; then
  grep -q '<script src="more-games.js"></script>' www/index.html && [ -s www/more-games.js ] && grep -q 'showList' www/more-games.js \
    || die "More Games is offered (moreGamesSupported:true) but more-games.js (with showList) is not loaded. See the more-games-exit skill"
fi

# ---- 5. Build ----------------------------------------------------------------------------------
OUTD="$P/builds/android"; mkdir -p "$OUTD"
icon_check() {   # the adaptive icon inside the APK must be the app icon
  [ -n "$ICON" ] || return 0
  local X; X="$(mktemp -d)"
  python3 - "$1" "$X" <<'PY' || die "could not read $1"
import sys, zipfile, struct, os
z = zipfile.ZipFile(sys.argv[1]); n = 0
for i in z.namelist():
    if i.startswith('res/') and i.endswith('.png') and not i.endswith('.9.png'):
        d = z.read(i)
        if d[:8] == b'\x89PNG\r\n\x1a\n' and struct.unpack('>II', d[16:24]) == (432, 432):
            open(os.path.join(sys.argv[2], '%d.png' % n), 'wb').write(d); n += 1
PY
  (cd "$W" && node "$KIT/scripts/make-android-icon.cjs" check "$X" "$RES/mipmap-xxxhdpi/ic_launcher_foreground.png") \
    || { rm -rf "$X"; die "the app icon is not in the APK (ICON CHECK FAIL)"; }
  rm -rf "$X"
}
log_build() {    # one line per build; old .apk/.aab files are removed before each copy
  [ -f "$OUTD/VERSIONS.md" ] || printf '# Build log\n\n| Date | Version (code) | Type | App name | Files |\n|---|---|---|---|---|\n' > "$OUTD/VERSIONS.md"
  echo "| $(date '+%Y-%m-%d %H:%M') | $VERSION_NAME ($VERSION_CODE) | $1 | $APP_NAME | $2 |" >> "$OUTD/VERSIONS.md"
}
BASE="$(echo "$APP_NAME" | tr -cd 'A-Za-z0-9')-$VERSION_NAME-$VERSION_CODE"
cd android && chmod +x gradlew
if [ "$MODE" = debug ]; then
  ./gradlew assembleDebug -q || die "Gradle debug build failed (full log above)"
  icon_check app/build/outputs/apk/debug/app-debug.apk
  rm -f "$OUTD"/*.apk "$OUTD"/*.aab
  cp app/build/outputs/apk/debug/app-debug.apk "$OUTD/$BASE-debug.apk"
  log_build debug "$BASE-debug.apk"
  echo "BUILT: builds/android/$BASE-debug.apk  (test build: install with windows\shortcuts\\11 Install APK on Phone.bat)"
else
  KS="$KEYSTORE"; [[ "$KS" == /* ]] || KS="$SD/$KS"
  # Never make a new key by accident: an update signed with a different key is refused by Google Play.
  # A new key is made only when secrets/android/ALLOW_NEW_KEY exists (first release of the studio, owner confirmed).
  if [ ! -f "$KS" ]; then
    if [ -f "$SD/ALLOW_NEW_KEY" ]; then
      echo "== Creating the keystore $KS (alias $KEY_ALIAS). One keystore signs every app."
      keytool -genkeypair -keystore "$KS" -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass "$STORE_PASS" -keypass "$KEY_PASS" -dname "CN=${ORG_NAME:-Studio}, O=${ORG_NAME:-Studio}" >/dev/null || die "keytool failed"
      chmod 600 "$KS"; rm -f "$SD/ALLOW_NEW_KEY"
      echo "KEY CREATED: back up $KS and its password now (USB or password manager). Lose it and every app needs a Google upload-key reset."
    else
      missing "keystore $(basename "$KS") not found in secrets/android/. Restore it from your backup (see README-KEYSTORE.md). Only for a studio's very first release: create secrets/android/ALLOW_NEW_KEY and build again"
    fi
  fi
  FP="$(keytool -list -v -keystore "$KS" -alias "$KEY_ALIAS" -storepass "$STORE_PASS" 2>/dev/null | grep -m1 'SHA256:' | sed 's/.*SHA256: *//')"
  [ -n "$FP" ] || die "cannot open the keystore $(basename "$KS") with the password and alias in signing.env"
  FPF="$SD/keystore-fingerprint.txt"
  if [ -f "$FPF" ]; then
    [ "$(tr -d '\r\n ' < "$FPF")" = "$(echo "$FP" | tr -d ' ')" ] || die "this keystore is not the one used before (fingerprint differs from keystore-fingerprint.txt). Google Play would refuse the update. Restore the original keystore"
  else
    echo "$FP" > "$FPF"
  fi
  echo "Upload key SHA-256: $FP  (must match Play Console > Setup > App signing > Upload key certificate)"
  SIGN=(-Pandroid.injected.signing.store.file="$KS" -Pandroid.injected.signing.store.password="$STORE_PASS"
        -Pandroid.injected.signing.key.alias="$KEY_ALIAS" -Pandroid.injected.signing.key.password="$KEY_PASS")
  ./gradlew bundleRelease assembleRelease -q "${SIGN[@]}" || die "Gradle release build failed (full log above)"
  icon_check app/build/outputs/apk/release/app-release.apk
  rm -f "$OUTD"/*.apk "$OUTD"/*.aab
  cp app/build/outputs/bundle/release/app-release.aab "$OUTD/$BASE-release.aab"
  cp app/build/outputs/apk/release/app-release.apk "$OUTD/$BASE-release.apk"
  log_build release "$BASE-release.aab, $BASE-release.apk"
  # Next upload needs a higher code AND name: 1.0.0 -> 1.0.1 (a bigger step, like 1.1.0, you set by hand)
  NEXT_NAME="$(echo "$VERSION_NAME" | awk -F. 'NF==3 && $3 ~ /^[0-9]+$/ {print $1"."$2"."$3+1; next} {print $0}')"
  sed -i -E "s/^VERSION_CODE=.*/VERSION_CODE=$((VERSION_CODE+1))/; s/^VERSION_NAME=.*/VERSION_NAME=\"$NEXT_NAME\"/" "$ENVF"
  echo "BUILT: builds/android/$BASE-release.aab  (upload this to Google Play)"
  echo "BUILT: builds/android/$BASE-release.apk  (same build, to test on a phone)"
  echo "NOTE: android.env is now version $NEXT_NAME (code $((VERSION_CODE+1))) for the next upload. Google Play refuses an upload that reuses a version code."
fi
if [ -d "$P/.git" ] && ! grep -qx "builds/" "$P/.gitignore" 2>/dev/null; then echo "builds/" >> "$P/.gitignore"; fi
