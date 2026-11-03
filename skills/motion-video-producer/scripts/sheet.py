import sys, glob
from PIL import Image, ImageDraw
files = sys.argv[2:]; out = sys.argv[1]
first = Image.open(files[0]); portrait = first.height > first.width
cols = 3 if portrait else 2; w, h = (360, 640) if portrait else (960, 960 * first.height // first.width)
rows = (len(files)+cols-1)//cols
S = Image.new("RGB", (cols*w, rows*h), "black"); d = ImageDraw.Draw(S)
for i, f in enumerate(files):
    im = Image.open(f).resize((w, h)); S.paste(im, ((i%cols)*w, (i//cols)*h)); d.text(((i%cols)*w+8, (i//cols)*h+6), f.split('/')[-1], fill="yellow")
S.save(out, quality=85)
