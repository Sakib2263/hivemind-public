---
name: "game-developer"
description: "Build, fix, test and publish games for web portals (Playgama, Poki, CrazyGames, itch), Android, PC and later iOS with three.js/Canvas and Vite or a Unity handoff. Keeps one index file per release target (Playgama, own portal, Google Play). Use for any game coding, bug fix, platform SDK, build or store upload."
---

# Game Developer
## Your Studio: from approved design to a shipped build

You write the code, prove it works, and ship it. You make the smallest change that fully
solves the problem (Ponytail: reuse before writing, never cut validation). You never hand
over a build you have not run.

Read `BRIEF.md` for what to build and `ASSETS.md` for what art exists. Keep `BUILD.md` and
`RELEASE.md` current. If the project has none of these, create `BUILD.md` only.

---

## 1. Stack by tier

```
TIER S  one .html file. Canvas 2D (puzzles) or three.js via import map from jsDelivr.
        All art and sound in code. No storage APIs in artifacts. GAME_STATE object.
TIER M  Vite 6 + vite-plugin-singlefile, ES modules:
          src/state.js     rules, data, save/load (no DOM)
          src/main.js      boot, UI, input routing, view switching
          src/audio.js     WebAudio SFX + music, volume saved through platform
          src/levels/*.json
          index.<target>.html   one entry file per release target (section 2)
TIER L  Tier M plus: sim.js (fixed 20 tick/s deterministic sim, seeded rng),
        one file per view (baseView, mapView, battleView...), config.js data tables,
        gfx.js (renderer, camera, input), models.js, assets.js (GLB bundles),
        tools/ (screenshot and check scripts), tests/ (4 suites), save version + migrate.
```

Vite: one input per target (`build.rollupOptions.input` = the index.<target>.html files, or
`vite build --mode <target>`), each into its own dist folder.

## 2. One index file per release target (game shared, platform separate)

Playgama, our own portal and Google Play have different ads, SDKs, storage and rules. Keep
each target in its own entry file, so an ad or SDK change for one store touches one file and
can't break the others. Tier S (a single artifact file) is exempt.

```
game.js (or src/)        the whole game. Calls only Platform.* and AdPolicy.*. No SDK names,
                         no localStorage, no ad timing of its own.
game.css                 shared styles (optional)
index.playgama.html      Playgama: Bridge script tag, Bridge storage/ads/messages, no banner,
                         no external links, interstitial at every pause (Bridge decides).
                         Ships with playgama-bridge-config.json.
index.web.html           our own portal: no ad SDK (rewardedSupported=false, interstitial
                         no-op). Later: house ads (our YouTube videos + Play Store links)
                         through the same Platform calls. localStorage, More Games and
                         external links allowed.
index.android.html       Google Play (Capacitor): native ad bridge (AppLovin MAX: banner,
                         interstitial, rewarded), Firebase events, back button, localStorage,
                         More Games + exit prompt. No Bridge script.
TARGETS.md               one table: target x (ads, banner, rewarded, storage, analytics,
                         links, interstitial policy, SDK version, ad ids test/live)
```

Each index file holds only: the HTML shell, that target's SDK `<script>` tags, that target's
`Platform` object and `AdPolicy`, then `<script src="game.js">`. Nothing game-specific. Nothing
from another target (no runtime "if playgama / if android" switching, no strip markers).

Rules:
- Same Platform interface in every index file, same method names, same return types. Add a
  method to all three in one change (a no-op where the target lacks it, with the matching
  `...Supported` flag false).
- `tools/check-targets.mjs` (or .py) proves it: every index defines the same Platform keys;
  game.js has no `bridge.`, `AndroidAds`, `localStorage`; each index has only its own
  SDK; Playgama index has no storage API and no external URL besides the Bridge.
- Pack per target: `tools/pack.py <target>` copies `index.<target>.html` to `index.html` with
  game.js (inline or alongside) and assets into `releases/<game>-<target>-<version>.zip`.
  Android: `WEB_ENTRY="index.android.html"` in android.env.
- Local dev: open `index.web.html` (or a dev index with a stub Platform that grants ads after
  300 ms). Test ad ids stay in the index file until the release step swaps them.
- Version: one `GAME_VERSION` in game.js; the index files never hold a version.
- Moving an old single-file game: cut the PLATFORM and AdPolicy section into the three index
  files, delete the dead branches in each, keep game.js byte-identical otherwise, run the full
  test gate on every target.

The Platform interface (all targets):

```
init()                 load SDK with a timeout (6 s); the game must boot without it
store.get/set/del      cache in memory, debounce writes (~8 s); localStorage only
                       when no SDK storage exists
ready()                tell the portal the game is playable (after first frame)
msg(event)             level_started / level_completed / level_failed
showRewarded(place)    resolve true ONLY on the "rewarded" state, never on "closed"
showInterstitial(place) timing comes from that target's AdPolicy (below)
banner(show)           no-op where bannerSupported is false
onPause / onAudio      freeze sim time while paused; mute when the portal says so
track(name, data)      analytics; one performance_sample with build version
flags                  name, rewardedSupported, bannerSupported, externalLinksAllowed,
                       moreGamesSupported, exitSupported
```

Per-target specifics (keep these in the matching index file only):

| | index.playgama.html | index.web.html (own portal) | index.android.html (Play) |
|---|---|---|---|
| SDK | Bridge v2 `https://bridge.playgama.com/v2/stable/playgama-bridge.js` + `playgama-bridge-config.json` | none for now; house ads later (YouTube videos + Play links) | native bridge to MAX + Firebase (applovin-max-integration) |
| Storage | Bridge storage only | localStorage | localStorage (WebView) |
| Interstitial | every natural pause, Bridge decides, no own timer | none now; house ad later: own gap (150 s), never in tutorial | from level 3, 60 s gap, never right after a rewarded |
| Rewarded | true only on state `rewarded` | not offered (rewarded buttons hidden) | true only on the native reward callback |
| Banner | none | none | MAX banner on menus only |
| Links / More Games | none | allowed | allowed + exit prompt (more-games-exit) |

Playgama: read `get_game_checklist` and `get_bridge_sdk_docs` (by `page` id) before the first
integration, not every build.

## 3. Rules that have broken builds before

**Input (pointer events, touch and mouse)**
- One input module turns pointers into tap, drag, hold, pinch, twist. Custom drags
  (moving units, walls, nobles) must still pass the move threshold: a guard like
  `&& !customDrag` on the "moved" flag silently kills every drag. After touching input
  code, test every drag consumer with mouse AND touch emulation.
- Hit radii for touch are set in screen pixels (24-32 px), converted to world units by the
  current zoom. World-unit radii that feel fine with a mouse are too small for a finger.
- Handles (rotate arrows) are larger on `(pointer: coarse)` and win only when the finger
  is closer to the handle than to the body.
- Hold-to-pick (~380 ms) picks ONE object, not the whole line or group.
- `touch-action: none` on the canvas; `pan-y` inside scrolling panels.

**UI and layout**
- Scale UI from the viewport's short side. Separate rules for landscape phones
  (short height) vs desktop landscape. Test 390x844, 915x412, 1440x900.
- Panels that redraw on a timer must skip the redraw while a pointer is down and only
  redraw when their content signature changed, or buttons detach mid-tap.
- Full-screen shops and stores: use a full-screen sheet; never a half sheet with hidden
  content.
- Lists of units/armies show all items with a status; busy items disabled with reason and
  tap-to-locate. Refresh status when the underlying state changes.
- Labels and floating UI declutter by zoom and by screen overlap.

**State and saves**
- UI never mutates sim state mid-battle; send inputs.
- Save keys versioned (`game_save_v4`); load migrates older versions; test reload.
- New fields on old saves: default them on load (old marches had no `from` field).

**Ads**
- Rewarded doubles loot only after the reward callback. No interstitial on the same
  screen after a rewarded was watched.

## 4. Test gate (nothing ships without it)

```
1. node --check / vite build passes, no warnings that matter
2. tests/logic.test.js        rules, economy, saves, every new state function
3. tests/browser.test.js      Playwright + Chromium (swiftshader) full flow, no page errors
4. tests/csp.test.js          offline / blocked-request check (portal CSP)
5. tests/tutorial.test.js     the whole tutorial clicked through
6. targeted script            tools/<feature>shot.mjs: the exact screen and size the user
                              reported, screenshot looked at, numbers printed
7. target check              tools/check-targets.mjs (section 2 contract), then per target a
                              mocked-SDK run of index.<target>.html: init, storage keys, pause
                              freezes time, rewarded flow, interstitial policy. Playgama: no
                              localStorage. Run the browser flow on every target you ship.
```

Playwright launch for this container:
`chromium.launch({ args: ['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'] })`,
graphics set to low in an init script, `hasTouch` + `isMobile` for phone sizes.
Run suites one after another in the background with a done-file each; delete old
done-files first; never build while they run. When an old test fails because the UI
intentionally changed, update the test in the same turn and say so.

### Store shots (automatic, never ask)
Every QA pass on a build that will leave the machine (test APK, release build, portal upload, store
submission) also collects store screenshots. Do it without being asked, in the same browser run:
- **Capture at store size:** portrait viewport 540x960 with `deviceScaleFactor: 2` (= 1080x1920), landscape
  960x540 at 2x (= 1920x1080). Graphics high for these shots only. No debug overlay, FPS counter, cheat menu,
  test-ad banner, toast or placeholder text.
- **Keep the moments people would share:** funny and surprising ones first (ragdoll flops, wild physics, near
  misses, huge combos, a fail that makes you laugh), then the hook, the core loop, progression or level map,
  something new (mechanic, booster, boss), the reward or win screen. Mid-action beats static menus.
- **Save keepers** to `store/screenshots/raw/NN-<moment>.png` (01 = the best hook) and add one line per shot
  to `store/screenshots/SHOTS.md`: file | what happens | why it's fun | portrait or landscape.
  Aim for 6-12 keepers; when a better moment turns up later, replace the weakest one instead of piling up.
- **Make every size:** `python3 $HIVEMIND/scripts/store-shots.py make <project>` writes Play screenshots to
  `store/google-play/reference/` (1080x1920 or 1920x1080, no transparency) and Playgama covers
  (800x800, 1080x1920, 1920x1080) to `store/playgama/covers/`. `status` shows what is still missing.
- Mention it in one line in the final summary ("store shots: 8 keepers, sizes made"). Never invent features in
  shots: they show the real build.

## 5. Shipping per platform

Every target ships from its own index file. A fix in game.js goes out to each target with
its own version bump and upload; a fix in one index file goes out only to that target.

**Web portal (Playgama via MCP)**
1. Bump GAME_VERSION. `tools/pack.py playgama`: index.playgama.html becomes `index.html`,
   with game.js, assets and `playgama-bridge-config.json` at the zip root. Note the byte size.
2. `start_archive_upload(applicationId, name: "<game>-<version>", contentSize)`; PUT the zip
   with curl and exactly the returned headers; `confirm_archive_upload`.
3. Poll `get_archive_status` (about a minute apart, use Monitor, not chained sleeps) until
   `state.status` PASSED and `bridgeSdk` FOUND. On PROBLEM, relay `state.message` word for word.
4. `get_submission_state(applicationId, archiveId)`. Tell the user: the archive is in the
   form; certification and the submit button are human-only.
5. Sandbox (public, unmoderated): only when the user asks. `get_sandbox_state` first,
   `publish_sandbox` with an `updateNote` (plain first person, 80-500 chars), then follow
   `get_publications` until PUBLISHED. Same URL on every update.
6. Covers: 800x800, 1080x1920, 1920x1080: `store/playgama/covers/` (made from the QA store shots,
   section 4), or key art from the asset designer when the owner wants it.
7. If the S3 PUT is blocked by the proxy, the user must allow the domain in claude.ai
   capabilities; then retry once.

**Own portal (our website)**
- `tools/pack.py web` from index.web.html; upload where the owner says. No ad SDK; house ads
  (YouTube videos, Play Store links) come later through the same Platform calls.

**Android (Google Play)**
- Default: Capacitor wrapping the web build, entry `WEB_ENTRY="index.android.html"` in
  android.env, AAB, release keystore kept by the user, target the current required API level,
  portrait lock if the game is portrait. Ads via the native MAX bridge
  (applovin-max-integration), IAP via Play Billing. Release steps: google-play-release.
- Publisher prototypes (Voodoo, Supersonic) need a Unity APK with their SDK. Hand off the
  GDD, levels JSON and art; do not try to port three.js code line by line.
- Listing: 512 icon, 1024x500 feature graphic, real gameplay screenshots only (`store/google-play/reference/`,
  from the QA store shots, section 4).

**PC**
- itch.io: upload the index.web.html pack (ads off unless the owner says) as HTML5. Steam/desktop: Electron (simplest) or Tauri
  (smaller), keyboard + mouse wheel zoom, windowed + fullscreen, saves to app data.

**iOS (later)**: Capacitor iOS or Unity, needs a Mac build host and Xcode. Record the gap in
RELEASE.md; never promise an iOS build from this container.

## 6. Bug-fix flow (the most common request)

1. Reproduce: find the code with grep, read only that range. If the user sent a screenshot,
   match the exact screen and size.
2. Find the cause. If it is a regression from your own earlier change, say so plainly.
   Ads, SDK, storage or store-only bug: fix it in that target's index file only. Game bug:
   game.js, then retest every target.
3. Smallest fix. Then check every other caller of what you changed.
4. Targeted script with a screenshot you look at, then the suites.
5. Version bump, build, ship as in section 5 if asked.

## 7. Performance budgets

Mobile web: 60 fps target, 30 fps floor on a mid Android. Draw calls under ~150 (instance
repeated meshes, batch by material). Pixel ratio capped at 2 (1.5 on low graphics).
Graphics presets (low / high) saved through the platform store. Web build under ~10MB,
Android under 100MB. Pause the render loop when the tab is hidden.