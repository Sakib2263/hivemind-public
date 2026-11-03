# Script and off workers: job body formats (read when sending one)

| worker | Extra header | Notes |
|---|---|---|
| android | none | Body = `debug` (test APK) or `release` (signed AAB + APK). See `templates/routing/android.md` |
| assets | none | Script, no model. Body: one `scripts/assets.py` command per line: `scan <folder>`, `add <zip or folder> [--type T] [--source URL] [--tags a,b]`, `peek <zip>`, `find <words>`, `list [type]`, `copy <pack>/<glob> . [--to assets/audio] [--ogg]`, `index`. Windows or WSL paths |
| files | none | Script, no model. Body: one `delete <path>` per line (inside the project, never .git) |
| upload | none | Script, no model. Body: line 1 file path, line 2 signed https amazonaws.com PUT url (Playgama archives, covers) |
| install | none | Script, no model. Body: apk path or empty (newest `builds/android/*.apk`). Installs on the USB phone; gets Windows adb once if missing |
| comfy | none | Script, no model. Body: shots file (default `shots.json`), optional `force`, `only=id,id`. AI clips and stills on the Windows GPU; needs `windows\shortcuts\14 Start Video Studio.bat` open. See `stacks/video.md` |
| video | none | Script, no model. Body: `build`, `vo`, `audio`, `render [cut]`, `verify` or `snap <cut>`: the motion-video-producer pipeline for that project |
| codex, codex-review | effort (codex) | Off until a ChatGPT plan is added; jobs sent anyway fall back to the free models |
| deepseek | model: hard | Off (pay-per-use). Falls back to the free DeepSeek model in opencode |
