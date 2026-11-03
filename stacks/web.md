# Web stack playbook (three.js / Canvas / Vite)

Skills: game-studio-lead (router), game-developer (code, SDKs, builds), game-asset-designer, google-play-release.

## Setup by start type
- **New:** Tier S = one HTML file. Tier M/L = Vite project (`npm create vite@latest`), modules per system.
- **Existing:** read BUILD.md / package.json, run it once, take baseline screenshots before changing anything.
- **Reskin:** `8 New Project.bat` copies the base. Then: new name and bundle id (android.env), swap the Theme
  (art, sounds, palette), change tuning data, keep game logic untouched. Done when presentation changes
  without logic edits.

## SDKs by target
| Target | SDK | Notes |
|---|---|---|
| Playgama | Playgama Bridge | Use the playgama-developer-console tools: launch steps, checklist, archive QA |
| Poki / CrazyGames | their JS SDKs | Ads only at natural breaks; loading and gameplay events |
| Android (Capacitor) | AdMob (@capacitor-community/admob), Play Billing plugin when IAP | Test ad ids until release; consent (UMP) for EU |
| Analytics | portal analytics, or GameAnalytics JS | Keep events small: start, level_start, level_end, ad_shown |
| Own portal (our site) | no ad SDK; house ads later (YouTube videos + Play links), localStorage | More Games allowed |

One entry file per target: `index.playgama.html`, `index.web.html` (own portal), `index.android.html`
(Google Play), all loading the same `game.js` (game-developer section 2). An ad or SDK change for one
store touches only its index file. Android builds use `WEB_ENTRY="index.android.html"` in android.env.

## Dev loop
plan (Claude) > opencode jobs (GLM features, DeepSeek mechanical) > review (Antigravity) > gate build >
gate security if coins, IAP, rewards > git-commit.

## QA
1. `node --check` / build passes.
2. Headless browser playthrough + screenshots at 390x844, 915x412, 1440x900; look at them.
3. Console has no errors; no network calls the portal blocks.
4. Android: debug APK on a real phone (`11 Install APK on Phone.bat`): touch, sound, back button, pause on home.
5. Gate `release` before anything public.

## Build and release
- Web portal: `tools/pack.py <target>` turns index.<target>.html into index.html, zipped by version,
  uploaded through the portal tools.
- Android: `10 Build Android App.bat` (debug APK / release AAB), then the google-play-release skill.
- iOS (later): Capacitor iOS needs a Mac or a cloud Mac build.
