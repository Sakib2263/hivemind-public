# More games + exit prompt (shared by every web game of yours)

Files here:
- `games.json`: the catalog (Play package id, name, 128px icon inlined so it works offline)
- `more-games.src.js`: the module source. Edit this, not the copy.
- `more-games.js`: built file. Copy it into each game folder, next to the game's .html
- `build.py`: rebuilds `more-games.js`; `--icons <folder>` adds or updates games from `<package id>.png` + `names.txt`

Full steps: the `more-games-exit` skill.
