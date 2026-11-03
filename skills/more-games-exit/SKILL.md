---
name: "more-games-exit"
description: "Add the Your Studio More games list and the back-button exit prompt (with cross-promo games) to any web game, browser or Android/Capacitor build."
---

# More games + exit prompt

One shared module for every Your Studio web game. Proven in a shipped Android game.
Kit folder: `D:\Work\hivemind\templates\more-games\` (`games.json`, `more-games.src.js`, `more-games.js`, `build.py`).
Plain language with the owner. Ponytail: reuse the module, never rewrite it per game.

## What the player gets
- **More games screen**: a list of our other games (icon, name, Get button). The current game is left out automatically.
- **Back button / gesture (Android)**:
  1. A panel or popup is open: back closes it.
  2. Any screen other than the home menu: back goes to the previous screen.
  3. Home menu: an exit prompt opens. Title, "Your progress is saved", 4 of our games, "Keep playing" and "Exit".
  4. Back again while the prompt is open, or tapping Exit: the game saves and closes.
- Tapping a game opens its Play Store page (the Play app on Android, a new tab in a browser).

## 1. Add the module to the game
1. Copy `more-games.js` from the kit folder into the game folder, next to the game's `.html`.
2. Load it before the game script: `<script src="more-games.js"></script>`.
3. Init once the game is ready:
```js
MoreGames.init({
  selfId: 'com.yourstudio.<thisgame>',      // the game's own bundle id, left out of the lists
  onBack: () => { /* return true if the game handled back */ },
  onExit: () => saveProgress(),              // save before closing
  sound: () => sfx.tap(),                    // optional tap sound
  title: 'Leave the cottage?',               // optional, match the game's voice
  accent: '#FFD966', ink: '#4B3E66', paper: '#FFFBF5', // match the game's palette
  mascot: MASCOT_SVG,                        // optional character beside the title
});
```
4. `onBack` must handle steps 1 and 2 above and return `true` when it did something. Return `false` on the home menu so the exit prompt opens. During gameplay, open the pause menu and return `true`.
5. More games screen: `MoreGames.renderList(document.getElementById('<list container>'))`.
6. A single-file game (no separate files allowed, like Playgama zips): paste the contents of `more-games.js` into an inline `<script>` instead.

## 2. Android side (Capacitor, Hivemind builder)
The game's `native-android/MainActivity.java` needs two things (copy from a shipped game, `<work folder>\My Game\native-android\MainActivity.java`):
- A back callback: `getOnBackPressedDispatcher().addCallback(...)` that runs `window.onAndroidBack()` and calls `finish()` only when the result contains `exit`.
- A `window.AndroidApp` interface: `exit()` runs `finishAndRemoveTask()`, and `openStore(id)` opens `market://details?id=` with an `https://play.google.com/store/apps/details?id=` fallback.
Without these, the browser build still works (links open the web store; Exit just closes the prompt).

## 3. Update the catalog (new game launched, new icon)
1. Put icons in a folder named by package id: `com.yourstudio.newgame.png` (square, any size).
2. Add `names.txt` there with lines like `com.yourstudio.newgame = New Game`.
3. Run `python build.py --icons <folder>` in the kit folder. It updates `games.json` and rebuilds `more-games.js`.
4. Copy the new `more-games.js` into each game that should show the new game, and ship it in that game's next update.
Only add games that are live on Google Play, so no link leads to a missing page.

## 4. Check (headless browser, 360x640 and 390x844)
- `MoreGames.games()` does not include the current game.
- On a non-menu screen `window.onAndroidBack()` returns `''` and goes back.
- On the menu, the first call opens the prompt with 4 games. The second call returns `'exit'`.
- "Keep playing" closes the prompt. Tapping outside the sheet closes it too.
- No console errors. The prompt fits without scrolling.
- On the phone: the back gesture never closes the game straight from the menu, and the game icons open the Play Store.

## Notes
- Icons are inlined (128px JPEG) so the list works offline. About 3 KB per game.
- Don't show the exit prompt more than once per back press. Don't put ads in it (Play policy on deceptive placements).