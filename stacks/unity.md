# Unity stack playbook

Skills: game-studio-lead (router), game-developer (shipping rules), the Unity plugin skills (unity-cli,
new-unity-project, levelplay-unity-integration, implement-in-app-purchases, optimize-web, ui, physics-3d-collision),
google-play-release. Full Unity plan and status: `plans/UNITY-PLAN.md`.

## Rules for agents in Unity projects
- Never hand-edit `.unity`, `.prefab` or `.asset` YAML. Change scenes and settings through the editor
  (Unity MCP) or an editor script run in batchmode.
- Search only `Assets/` and `Packages/`. Never read `Library/`, `Temp/`, `Logs/`.
- Batchmode can't open a project the editor has open: close the editor, or use Unity MCP in the open editor.
- Always commit `.meta` files with their assets. Large art and audio: Git LFS.
- Pin the Unity version from `ProjectSettings/ProjectVersion.txt`; write code for that version only.

## Setup by start type
- **New:** create it with Unity Hub (or the new-unity-project skill) inside the project folder Hivemind made,
  using the pinned version. Then the layout: `Assets/_Game/{Scripts,Art,Audio,Prefabs,Scenes,Data}`,
  assembly definitions `Game.Core`, `Game.Presentation`, `Game.Tests`.
- **Existing:** open once in the editor, note the version, the render pipeline (URP / Built-in), the SDKs
  in `Packages/manifest.json` and `Assets/Plugins`, and the build targets. Write them into BUILD.md.
- **Reskin:** `8 New Project.bat` copies the base without Library/Temp. Then in the editor: Player Settings
  (product name, company, bundle id, icon), swap art/audio/Theme ScriptableObjects, change tuning ScriptableObjects.

## SDKs by target
| Target | SDK | Skill / note |
|---|---|---|
| Android / iOS ads | LevelPlay (ironSource) or the publisher's stack | levelplay-unity-integration |
| IAP | Unity IAP | implement-in-app-purchases |
| Voodoo / Supersonic / Homa test | TinySauce / Supersonic SDK / Homa Belly | follow the publisher's current doc; their test build checklist wins |
| Analytics | publisher SDK, GameAnalytics or Firebase | one wrapper class, events like the web stack |
| WebGL portal | portal JS SDK through a .jslib bridge | optimize-web skill for size |

## Dev loop
plan (Claude) > C# scripts by opencode / Claude > editor changes by Claude through Unity MCP >
compile + EditMode tests (relay `unity` worker, planned) > review > commit.
Until the relay `unity` worker exists: the owner presses Play / Build in the editor, Claude reads the Console
(via Unity MCP or the Editor.log tail) and fixes.

## QA
1. Compiles with no errors or warnings in our code; EditMode tests pass.
2. Play in editor: the changed flow, at portrait 1080x1920 and the smallest supported aspect.
3. Android: development build on a real phone, then the profiler for frame time if it's 3D.
4. Publisher SDK: their integration test scene or debug panel shows ads, events and IAP working.
5. Gate `release` before anything public.

## Build and release
- Android: Unity build (APK for tests, AAB for Play), signed with the kit's `secrets/android/signing.env`
  keystore (UNITY-PLAN U6), then the google-play-release skill.
- WebGL: Brotli or Gzip, under the portal's size limit, browser smoke test.
- iOS (later): Xcode export, needs a Mac or a cloud Mac.
