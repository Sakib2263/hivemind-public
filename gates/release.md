# Gate: release

You are checking a build before it goes public. Do not fix anything. Report only.
Check only what applies to the target named in the task (web portal, Android, PC, iOS).

1. The build gate passes (build runs, tests pass). Run them again here.
2. Version number went up since the last release (RELEASE.md or package / build config).
3. No debug or cheat code ships: test menus, unlock-all, god mode, verbose logs, local test URLs.
4. Ads and IAP: test IDs replaced with live ones only where the task says so; no ads in the tutorial;
   rewarded ads only on a real reward; interstitials never right after a rewarded ad.
5. Target entry: the pack was built from that target's own index file (index.playgama.html,
   index.web.html or index.android.html; see game-developer section 2). Run `tools/check-targets.*`
   if the project has it: same Platform keys in every index, no SDK names in game.js, each index holds
   only its own SDK. Projects still on one shared index.html: STATIC ONLY, note it.
6. Web portals (Playgama, Poki, CrazyGames, own portal): platform SDK present and initialised, game starts
   offline-safe, no external calls the portal blocks, loading under the portal's size limit.
   Playgama: no storage API, no URL besides the Bridge, config json at the zip root.
   Own portal: no third-party ad SDK; rewarded buttons hidden.
7. Android: release build (not debug), signed, target SDK current, app id and version code correct,
   built from `WEB_ENTRY="index.android.html"`, no Playgama Bridge script inside.
8. Google Play: run `python3 "$HIVEMIND/scripts/check-store-assets.py" .` and copy its table.
   Any MISSING or FIX line = FAIL, with the line, so the lead can ask the owner for that asset or text.
9. iOS / App Store text: no emojis.
10. Screens: UI fits portrait phone 390x844, landscape phone 915x412 and desktop 1440x900
   (run a headless screenshot if possible, else STATIC ONLY).

Output, short: one line per check (PASS / STATIC ONLY / FAIL / n/a), then
`GATE release: PASS | PASS (STATIC ONLY) | FAIL | NEEDS-REVIEW`
and the one human step left (for example "upload the archive in the console").
