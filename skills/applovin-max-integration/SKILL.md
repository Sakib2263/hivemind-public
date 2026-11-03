---
name: "applovin-max-integration"
description: "Add AppLovin MAX ads (AdMob, Mintegral, Unity, Liftoff bidding) and Firebase to a Hivemind web game built as an Android app with Capacitor."
---

# AppLovin MAX + Firebase for Hivemind web games (Android)

Proven on a shipped game (com.yourstudio.mygame), Oct 2026. Reference project: `<work folder>\My Game\native-android\`.
Plain language with the owner. Ponytail: copy the reference files, change only what the project needs.

## 1. Ask the owner (one message)
- MAX SDK key, rewarded and interstitial ad unit IDs (banner only if asked)
- AdMob app ID (test builds can use Google's test ID `ca-app-pub-3940256099942544~3347511713`; release refuses it)
- Privacy policy URL
- Firebase: drop `google-services.json` in the project root (must contain the app's package name)

## 2. Game side (JS)
The game calls `window.AndroidAds.showRewarded(placement)` / `showInterstitial(placement)` and waits for `window.onAdResult(ok)`.
- A `false` return = no ad ready: finish with no reward and toast "No video ready yet".
- Without `AndroidAds` (browser, or no SDK key) the game shows its own mock ad, so every flow stays testable.
- Back button: native calls `window.onAndroidBack()`; return `'exit'` to close the app, anything else = handled.

## 3. Native side: `<project>/native-android/` (copy from the reference)
- `app/src/main/java/com/yourstudio/ads/AdsBridge.java`: MAX init, terms + privacy flow, rewarded/interstitial load with backoff retry, `onAdResult` called exactly once per show. Reads string resources `hm_*`.
- `MainActivity.java` (no package line; the builder keeps the generated one): `AdsBridge.attach(...)` after `super.onCreate`, plus the back-press callback.
- `app.gradle`: Mintegral maven repo, `minSdkVersion 24`, pinned deps:
  - `com.applovin:applovin-sdk:13.6.4`
  - `com.google.android.gms:play-services-ads-identifier:18.2.0`
  - `androidx.recyclerview:recyclerview:1.3.2` (Mintegral shows INVALID INTEGRATION without it)
  - adapters: `google-adapter:25.5.0.0`, `mintegral-adapter:17.2.11.0`, `unityads-adapter:4.21.0.1`, `vungle-adapter:7.7.9.1` (Liftoff)
  - Firebase: `platform('com.google.firebase:firebase-bom:33.7.0')` + `firebase-analytics`
- `manifest-application.xml`: AdMob `APPLICATION_ID` meta-data pointing at `@string/hm_admob_app_id`.
- `ads.example.env` (committed, placeholders, `APPLOVIN_SDK_KEY=NONE`).

## 4. Secrets
Real values go in `hivemind\secrets\android\<APP_ID>.ads.env` (git-ignored), never in the project:
```
APPLOVIN_SDK_KEY=...
MAX_REWARDED=...
MAX_INTERSTITIAL=...
ADMOB_APP_ID=ca-app-pub-...~...
PRIVACY_URL=https://...
# optional: TEST_DEVICE_IDS=<phone advertising ID>  (never leave a key empty: release refuses empty values)
```
The builder turns each `KEY=value` into a string resource `hm_<key>`.

## 5. Build (relay `worker: android`)
`scripts/android-build.sh` handles `native-android/` (copies app/, applies app.gradle, inserts manifest lines, swaps MainActivity), copies `google-services.json` into `android/app/`, and refuses a release while any ads value is empty, NONE, test or Google's test ID.
`android.env`: set `SPLASH_COLOR` for a dark launch screen. Release builds bump VERSION_CODE and the patch version (1.0.1 -> 1.0.2) after each build; Play refuses a reused code.

## 6. Test on the phone
1. Debug APK, open the MAX Mediation Debugger: every network must say COMPLETE. Fix any MISSING dependency it names.
2. Register the phone in MAX test mode (dashboard, or `TEST_DEVICE_IDS`) so the owner's clicks don't count.
3. Rewarded: reward only after close with a reward. Interstitial: game continues after close. No ad ready: game never hangs.
4. Check a Firebase Analytics session shows up (DebugView).

## Pitfalls seen
- MAX 13: test device IDs go on `AppLovinSdkInitializationConfiguration.builder(key).setTestDeviceAdvertisingIds(...)`, not on settings.
- `AppLovinSdkInitializationConfiguration.builder(key)` takes the key only (no context).
- MAX needs minSdk 24; Capacitor defaults to 23.
- Before release: `app-ads.txt` on the developer website, Data safety form lists advertising ID, approximate location, diagnostics, shared with ad networks.