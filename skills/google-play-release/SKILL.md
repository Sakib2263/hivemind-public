---
name: "google-play-release"
description: "From a tested build to a ready Play Store listing: app facts, signing key check, signed release build from index.android.html, store screenshots, ChatGPT art prompts, listing text and the Play Console checklist."
---

# Google Play Release

From a tested build to a ready Play Store listing. Claude does the checks, the build, the screenshots
and the prompts. ChatGPT (or another image tool) makes the art. The owner uploads in Play Console.

House style: plain spoken English, short. Files as `.md`. No emojis anywhere in store text.

Related skills: game-developer (build and QA), game-asset-designer (art direction, palette),
ua-aso-manager (keywords and ASO strategy), motion-video-producer (a real promo video),
applovin-max-integration (ads), more-games-exit (cross-promo and exit prompt).
Hivemind kit: `templates/ROUTING.md` section 9 (Android builds), `scripts/android-build.sh`.

## 1. Confirm the app facts first (ask if missing, never guess)

Test APKs need none of this: they build with stand-in names. Before the FIRST release, read
`<project>/android.env` and `project.yaml` (store_title) and ask the owner in ONE message for anything
missing or unconfirmed. Decide the name with ASO first (ua-aso-manager: keyword research, competitor titles),
then lock the bundle id:

| Fact | Rule | Suggest |
|---|---|---|
| Store title | max 30 characters; main keyword in it; no "best", "#1", "free", prices or emojis | 3 options from ASO research |
| App name (under the icon) | short, max 30; can differ from the store title and change in any update | short form of the title |
| Bundle id (APP_ID) | lowercase words joined by dots; can NEVER change after the first upload | BUNDLE_PREFIX from signing.env + game name |
| Icon source | square PNG 1024x1024, no text badges | ask, or make it in step 5 first |
| Version | VERSION_NAME players see (1.0.0); VERSION_CODE goes up every upload | 1.0.0 / 1 |
| Orientation | portrait, landscape or any | portrait for casual |
| Store facts | category, contact email, privacy policy URL, ads yes/no, IAP yes/no, target age | ask |

Write the answers into `android.env` (APP_NAME, APP_ID, ICON), `project.yaml` (store_title) and
`store/google-play/LISTING.md` (store facts). The title can still change later; the bundle id can't.

Versions: every Play upload needs a higher VERSION_CODE and a new VERSION_NAME (1.0.0 -> 1.0.1 for a small
update, 1.1.0 for a bigger one). The release build bumps both in `android.env` after it finishes. Never reuse
a number that was uploaded.

## 2. Check the signing key BEFORE every release build

One upload key (`hivemind\secrets\android\<name>.keystore` + `signing.env`) signs every Your Studio app.
An update signed with a different key is refused by Google Play, so never let a build make a new key by accident.

1. List `hivemind\secrets\android\`. It must hold `signing.env` and the keystore file named in it
   (KEYSTORE=). Never print or repeat the password.
2. Keystore missing:
   - Anything already on Google Play from this studio, or a new computer: ask the owner to restore the whole
     `secrets\android\` folder from the backup (USB or private cloud), following `README-KEYSTORE.md` there. Stop until it is back.
   - The studio's very first release ever: confirm with the owner in one message, then the owner runs
     `windows\shortcuts\10 Build Android App.bat` and chooses release (or Claude creates `secrets\android\ALLOW_NEW_KEY`
     after that explicit yes). The build makes the key once and deletes the marker.
   - Without the key or that marker the build stops with `MISSING: keystore ... not found`. Never work around it.
3. Fingerprint: every release build prints `Upload key SHA-256: ...` and compares it with
   `secrets\android\keystore-fingerprint.txt` (written on the first release). A mismatch stops the build: the
   wrong keystore is in place. For an app already on Play, the owner can also compare it with
   Play Console > Setup > App signing > Upload key certificate.
4. After a new key is made: tell the owner, the same day, to back up the whole `secrets\android\` folder in two
   places (USB and private cloud) and keep the password in a password manager. Don't copy the keystore through
   the device bridge yourself: binary files can change in transit. If the key is ever lost, Play App Signing
   keeps the app safe: the owner requests an upload key reset in Play Console.

## 3. Build

0. The Play build comes from `index.android.html` only (game-developer section 2). Check
   android.env has `WEB_ENTRY="index.android.html"` and run `tools/check-targets.mjs`. Ad ids:
   test ids in debug builds; live MAX/AdMob ids go into index.android.html (and the native
   config) only for the release build, after the owner gives them. Never edit the Playgama or
   own-portal index files for a Play change.
1. Debug APK first: relay `worker: android`, body `debug` (or `windows\shortcuts\10 Build Android App.bat`).
   The owner installs it with `windows\shortcuts\11 Install APK on Phone.bat` and plays it once on a real phone.
2. Run the gates: `build`, `security` (if coins, IAP, ads rewards or accounts), then `release`.
3. Release: relay `worker: android`, body `release`, only after step 2 passes.
   Output: `builds/android/<name>-<version>-<code>-release.aab` (upload) and `.apk` (same build, phone test).
   Read `.last`: check the `Upload key SHA-256` line and the new version noted for the next upload.
4. Never upload, publish or submit anything yourself. The owner uploads the AAB in Play Console.

Unity project? Its build comes from Unity (Hivemind `stacks/unity.md`); the key check and the listing steps
are the same.

## 4. Capture reference screenshots from the tested build

These usually exist already: every QA pass keeps store shots automatically (game-developer, "Store shots"):
keepers in `store/screenshots/raw/` with `SHOTS.md`, sized by `python3 $HIVEMIND/scripts/store-shots.py make
<project>` into `store/google-play/reference/`. Check `store-shots.py status <project>` first; capture more
only when there are fewer than 4 good ones or the build changed what they show. Never ask the owner for them.
Use the same headless browser QA you already run (game-developer test gate), on the build that passed:
- Portrait games: 1080x1920 (9:16). Landscape: 1920x1080. At least 4 shots; Play needs 3+ at 1080px for games
  to be eligible for large-format placements, 2 minimum to publish, 8 maximum per device type.
- Pick real moments, in this order: the hook (most exciting gameplay), the core loop, progression or a level map,
  variety (new mechanic, booster, boss), the reward or win screen.
- No debug overlays, cheat menus, test ads, toasts or placeholder text in the shots.
- Save to `store/google-play/reference/01-hook.png` and so on, and list them in LISTING.md with one line each
  on what the shot shows.

## 5. Write the ChatGPT prompt pack

Write `store/google-play/CHATGPT-PROMPTS.md`. Every prompt starts with the same context block, so the owner
can paste prompts one by one into the same ChatGPT chat.

```
CONTEXT (paste first)
Game: <name>. Genre: <genre>. Platform: Android phones, Google Play.
Player fantasy in one line: <...>. Core loop: <...>. What makes it different: <...>.
Target players: <age range, casual / midcore, regions>.
Art style: <from the game: 2D / 3D, pastel / bold, palette hex codes>. Mood: <...>.
I will attach real screenshots from the game. Keep the art faithful to them: same characters,
colours and UI style. Do not invent features the game does not have.
```

Then one section per asset. Each says what to attach, the exact output spec, and the rules:

1. **App icon.** Attach 2 reference shots. "Make 3 icon options, 1024x1024, square, full-bleed, no rounded
   corners (Play rounds them), no text, no badges, no 'free' or ranking signs, one clear subject, readable at
   48px, strong silhouette, high contrast against both light and dark backgrounds." Final upload: 512x512
   32-bit PNG, max 1 MB. The 1024 version goes to `store/icon-1024.png` for the app build.
2. **Feature graphic.** Attach the hook shot. "1024x500, landscape. Key art of <hero/moment>. Keep the main
   subject and any title in the centre area; edges may be cut off. Optional game name in a bold readable
   font; no other text, no ranking, price or award claims, no device frames." Final upload: JPEG or 24-bit
   PNG, no transparency.
3. **Screenshots.** Attach each reference shot in order. "Turn this real gameplay screenshot into a store
   screenshot, 1080x1920 portrait (or 1920x1080 landscape). Keep the gameplay image itself unchanged and
   readable. Add a short caption at the top: <2 to 5 words>. Caption font bold, high contrast, consistent
   across all screenshots. Background colour from the palette <hex>. No fake UI, no device frame, no
   ranking or price claims." Write the caption for each shot yourself (benefit first: "Merge to win",
   "Beat 200 levels"), one consistent set. Final upload: JPEG or 24-bit PNG, no transparency, 2 to 8 images.
4. **Title options.** "Give 5 app name options, max 30 characters each, with the main keyword naturally
   included. No 'best', '#1', 'free', prices, emojis or all caps."
5. **Short description.** "5 options, max 80 characters each. Say what the player does and why it is fun.
   No emojis, no special characters or symbols, no repeated punctuation, no capitals for emphasis, no
   ranking, award, testimonial or price claims, no calls to action like 'download now'. Full stop only at
   the end, and only if there are 2 sentences."
6. **Full description.** "Max 4000 characters (aim for 1500 to 2500). Opening 2 lines that hook (they show
   before 'more'). Then: what you do, key features as short plain lines, modes or content, and a closing
   line about updates. Use the keywords <list from ua-aso-manager> naturally 2 to 4 times each, no keyword
   stuffing. No emojis. No claims we can't prove. No other games' or brands' names."
7. **Promo video prompts (only when the owner asks).** Two options:
   - Real capture (preferred): a 15 to 30 second edit of real gameplay, made with motion-video-producer.
   - AI video tools (Veo, Kling, Runway, Sora): a shot list of 4 to 6 shots, each with a prompt line
     (subject, action, camera, style, palette, length), real gameplay recreated faithfully, gameplay visible
     in the first 10 seconds, captions, no sound needed for understanding.
   Upload rules: a public or unlisted YouTube video, ads and monetisation off, not age-restricted,
   embeddable, single video URL. Only the first 30 seconds autoplay.

Fill every `<...>` from the project (BRIEF.md, GDD, palette, ASSETS.md). Anything you don't know: ask once,
or mark it TODO in the file. Don't invent facts about the game. When the owner asks for the store text
itself, write it directly into LISTING.md under the same rules.

## 6. Check what comes back

When the owner drops the made files into `store/google-play/final/` (names: `icon.png`,
`feature-graphic.png`, `screenshot-01.png` ...), run the Hivemind checker and show its table:
`python3 <hivemind>/scripts/check-store-assets.py <project>`. It also checks the icon source, name,
bundle id and the LISTING.md text. Any MISSING or FIX line: ask the owner for it, or write the prompt
for it. Run it again before the release build and before you say "ready to publish".

LISTING.md must hold these lines (the checker reads them):
```
Title: <store title, max 30>
Short description: <max 80>
Category: <Play category>
Contact email: <email>
Privacy policy: <URL>

## Full description
<max 4000 characters>
```

What the checker and the rules expect:

| Asset | Must be |
|---|---|
| icon.png | 512x512, PNG, 32-bit with alpha allowed, max 1 MB |
| feature-graphic | 1024x500, JPEG or 24-bit PNG, no alpha |
| screenshots | 2 to 8, JPEG or 24-bit PNG, no alpha, each side 320 to 3840 px, long side max 2x the short side; games: 3+ at 1080 px or more for large-format |
| title | max 30 characters |
| short description | max 80 characters, rules above |
| full description | max 4000 characters |

Convert or resize only when asked (for example 1024 icon to 512, or removing alpha from a PNG).
Check file names too: a double extension (`icon.png.png`) breaks the build path.

## 7. Play Console checklist (the owner does these)

Write it into LISTING.md as checkboxes, with the answers you already know filled in:
- App created with the confirmed name, default language, game or app, free or paid.
- App content: privacy policy URL, ads declaration, app access (test login if needed), content rating
  questionnaire, target audience (under 13 means the Families policy applies), data safety form
  (what the ads and analytics SDKs collect), news and government sections: no.
- `app-ads.txt` on the developer website when the game has ads.
- Store listing: the texts and graphics from steps 5 and 6, category, contact email.
- Testing: upload the AAB to Internal testing first and test on a phone. A new personal developer account
  must run a closed test (currently 12 testers for 14 days) before production; organisation accounts don't.
- Production: roll out, starting with a staged percentage if the game has ads or IAP.
- After launch: hand keyword and screenshot tests to ua-aso-manager.

## Output

- `android.env` and `store/google-play/LISTING.md` (facts, captions, checklist)
- `store/google-play/reference/` (screenshots from the tested build)
- `store/google-play/CHATGPT-PROMPTS.md` (the prompt pack)
- the build paths and the upload key fingerprint from step 3
End with: what is ready, what the owner must do next (one line each), and what you could not check.