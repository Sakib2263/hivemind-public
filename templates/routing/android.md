# Android builds (read only for APK / release work)

1. Read the project's `android.env` (template: `templates/android.env`). Unity project? Stop: Unity builds
   follow `plans/UNITY-PLAN.md`.
2. Test APK (`debug`): ask nothing. An undecided name or bundle id gets a stand-in that is not saved.
   Release: missing or unconfirmed APP_NAME, APP_ID (bundle id) or ICON (1024x1024 PNG): ask the owner in one short
   message, with a suggestion (BUNDLE_PREFIX from `secrets/android/signing.env` + the game name). The bundle id can never change after the first Play
   upload, so always confirm it before the first release. ICON is required for release, optional for debug.
3. Write the answers into `android.env`, then send a relay job: `worker: android`, body `debug` or `release`.
4. `.last` shows `BUILT:` paths in `<project>/builds/android/`, or `MISSING:` (ask and resend), or `FAIL:`.
   A good build also shows `ICON CHECK: PASS` (the APK's adaptive icon is the app icon). `builds/android/` keeps only
   the newest build; every build is a line in `builds/android/VERSIONS.md`.
   Before saying a build is ready: the owner installs it and looks at the icon, More Games (if offered) and back on Home.
5. Release signing: one keystore signs every app, set in `secrets/android/signing.env` (never committed).
   If it's missing (MISSING: signing setup), the owner runs `windows\shortcuts\10 Build Android App.bat` once and
   chooses release; it asks for studio, bundle start, keystore, alias and password. After that the relay
   builds releases alone. Never print or repeat the keystore password in chat or files outside secrets/.
6. Not set up yet ("Android build tools are not installed")? Tell the owner to run `6 Optional - Android Build Tools.bat`.
7. Before a release build and before saying "ready to publish": run
   `python3 <hivemind>/scripts/check-store-assets.py <project>` (icon, name, bundle id, store icon, feature
   graphic, screenshots, title, descriptions, privacy policy, contact, category). For every MISSING or FIX line,
   ask the owner in one message: they give the file or text, or Claude writes the ChatGPT prompt pack for it.
   Store listing and Play Console steps: the `google-play-release` skill.

Free models and their free periods change: if one stops working, run `opencode models opencode`,
pick a new `-free` id, and update `config/models.env`.
