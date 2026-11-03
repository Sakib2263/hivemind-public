# Stacks: pick the engine once per project

(Videos and content series are not games: they follow `video.md`.)

Every game project starts with an intake that writes `project.yaml` at the project root
(`shortcuts\8 New Project.bat` asks the questions; Claude asks them in chat when the file is missing).
After that, every step (SDKs, building, QA, release) follows the playbook for that stack:
`web.md` or `unity.md`. No separate agent per stack: one router (game-studio-lead) + these playbooks.

## The intake questions
1. Start: new, existing, or reskin (copy a base game). Only a folder name is asked (a working name;
   existing projects can be renamed). The game title, app name and bundle id are decided later, before the
   first release, with ASO.
2. Engine: web (three.js / Canvas / Vite) or Unity. Unity is detected automatically in existing projects.
   Either engine can build every target below.
3. Target platforms: Android, iOS (later), web.
4. Android: where it goes: Google Play, third-party stores (Samsung, Xiaomi, Huawei, Amazon...), or a test APK only.
5. Mobile SDKs (Android, iOS): own (only our SDKs) or publisher (Voodoo, Supersonic, Homa, other).
6. Web: where it goes: Playgama, Poki, CrazyGames, own website, other.
7. Tier: S prototype, M small scalable game, L depth game (game-studio-lead section 1).

## Which engine (decide by the target and the publisher, not by habit)

| Situation | Engine | Why |
|---|---|---|
| Web game (Playgama, Poki, CrazyGames, own website) | web (or Unity WebGL for a Unity game) | Small builds, fast loads, portal SDKs are JS |
| Mechanic test, playable ad, Tier S prototype | web | One HTML file, the AI workers can run and test it headless |
| Simple Android game with no publisher SDK | web + Capacitor | Same code as the web build, `10 Build Android App.bat` |
| Mobile with publisher SDKs (Voodoo, Supersonic, Homa) | Unity | Their SDKs and test builds are Unity |
| Mobile with own SDKs only | web or Unity | web if it is 2D or light 3D; Unity if 3D-heavy |
| 3D-heavy, physics-heavy or iOS-first game | Unity | Engine features, native performance, Xcode export |
| Existing Unity project, or a reskin of one | Unity | Keep the codebase |
| Unsure | web | Cheapest to try; port to Unity only when a publisher asks |

## How the stacks differ

| | Web | Unity |
|---|---|---|
| Who builds | free workers (opencode GLM / DeepSeek), Claude reviews | Claude + workers for C# scripts; scenes and prefabs only through the editor (Unity MCP) |
| QA | headless browser tests + screenshots at 390x844, 915x412, 1440x900 | batchmode compile + EditMode tests, console check, then device / browser test |
| Android build | Capacitor: `10 Build Android App.bat` or relay `android` | Unity build (relay `unity` worker, planned: UNITY-PLAN U2) |
| SDKs | portal JS SDKs, AdMob through Capacitor | LevelPlay, Unity IAP, publisher SDKs, Firebase / GameAnalytics |
| Status in Hivemind | ready | partly ready: playbook yes, relay worker and gate planned (plans/UNITY-PLAN.md) |

## Reskins (both stacks)
A reskin is a copy of a base game with a new name, bundle id, look and tuning. Follow the AI OS GameDev idea:
game logic raises events; the look lives in a Theme (sounds, effects, art) and the numbers in tuning data.
The first reskin of a game is where the Theme and tuning get pulled out of the code (rule of two).
