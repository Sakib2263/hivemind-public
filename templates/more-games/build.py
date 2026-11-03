"""Rebuild more-games.js from games.json + more-games.src.js. Optional: --icons <folder> adds/updates
games from <package id>.png (or .jpg) files and a names.txt ("id = Name" per line).
Run: python build.py   then copy more-games.js into each game folder (next to the game's .html)."""
import json, sys, os, base64, io
here = os.path.dirname(os.path.abspath(__file__))
games = json.load(open(os.path.join(here, 'games.json'), encoding='utf-8'))
if '--icons' in sys.argv:
    folder = sys.argv[sys.argv.index('--icons') + 1]
    names = {}
    nf = os.path.join(folder, 'names.txt')
    if os.path.exists(nf):
        for line in open(nf, encoding='utf-8'):
            if '=' in line: k, v = line.split('=', 1); names[k.strip()] = v.strip()
    from PIL import Image
    for f in sorted(os.listdir(folder)):
        gid, ext = os.path.splitext(f)
        if ext.lower() not in ('.png', '.jpg', '.jpeg', '.webp'): continue
        im = Image.open(os.path.join(folder, f)).convert('RGB').resize((128, 128), Image.LANCZOS)
        buf = io.BytesIO(); im.save(buf, 'JPEG', quality=82)
        icon = 'data:image/jpeg;base64,' + base64.b64encode(buf.getvalue()).decode()
        g = next((x for x in games if x['id'] == gid), None)
        if g: g['icon'] = icon; g['name'] = names.get(gid, g['name'])
        else: games.append({'id': gid, 'name': names.get(gid, gid.split('.')[-1].title()), 'icon': icon})
    json.dump(games, open(os.path.join(here, 'games.json'), 'w', encoding='utf-8'), indent=1)
src = open(os.path.join(here, 'more-games.src.js'), encoding='utf-8').read()
open(os.path.join(here, 'more-games.js'), 'w', encoding='utf-8').write(src.replace('__GAMES__', json.dumps(games)))
print('more-games.js:', len(games), 'games')
