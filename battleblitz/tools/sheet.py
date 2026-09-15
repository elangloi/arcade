"""Contact sheet: uv run python sheet.py <cast> <out.png> [start] [count] [only8]"""
import sys, json
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parent.parent
cast, out = sys.argv[1], sys.argv[2]
start = int(sys.argv[3]) if len(sys.argv) > 3 else 0
count = int(sys.argv[4]) if len(sys.argv) > 4 else 48
only8 = len(sys.argv) > 5
man = json.load(open(ROOT/"assets"/cast/"manifest.json"))
ms = [m for m in man["members"] if m.get("file","").endswith(".png") and (not only8 or m.get("bpp") != 1)][start:start+count]
cell = 150; cols = 8; rows = (len(ms)+cols-1)//cols
sheet = Image.new("RGB", (cols*cell, rows*cell), (70,70,70)); d = ImageDraw.Draw(sheet)
for i,m in enumerate(ms):
    im = Image.open(ROOT/"assets"/cast/m["file"]).convert("RGBA")
    s = min((cell-4)/im.width, (cell-18)/im.height, 1.0)
    im = im.resize((max(1,int(im.width*s)), max(1,int(im.height*s))))
    x,y = (i%cols)*cell, (i//cols)*cell
    d.text((x+2,y+1), f"{m['num']} {m['name'][:24]}", fill=(255,255,0))
    sheet.paste(im, (x+2,y+14), im)
sheet.save(out); print(out, sheet.size, len(ms))
