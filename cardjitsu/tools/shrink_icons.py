"""Trim the extracted card icons: the art is shown at 28-40% scale, so one decimal of precision is
plenty. Run after extracting (see README): uv run --project ../../flash/tools python shrink_icons.py"""
import re, os, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / 'assets' / 'icons'
num = re.compile(r'-?\d+\.\d+')
before = after = 0
for d in sorted(ROOT.iterdir()):
    f = d / 'defs.svg'
    if not f.exists(): continue
    s = f.read_text()
    before += len(s)
    head, body = s.split('<defs>', 1)    # leave the XML declaration alone
    body = num.sub(lambda m: ('%.1f' % float(m.group())).rstrip('0').rstrip('.'), body)
    s = head + '<defs>' + body
    f.write_text(s)
    after += len(s)
    snd = d / 'sounds'
    if snd.is_dir() and not any(snd.iterdir()): snd.rmdir()
print(f'{before/1e6:.1f} MB -> {after/1e6:.1f} MB')
