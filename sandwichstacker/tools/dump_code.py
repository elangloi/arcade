"""Decompile every piece of ActionScript in the SWF -> ../decompiled/code/*.txt"""
from pathlib import Path
import swfraw, avm1
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'decompiled' / 'code'; OUT.mkdir(parents=True, exist_ok=True)

body, pos, hdr = swfraw.load_body()
lines = [f'# main timeline: {hdr}']
frame = 1
sprites = {}
def walk(tags, ctx, lines, frame_start=1):
    frame = frame_start
    for code, name, tb in tags:
        if name == 'ShowFrame': frame += 1
        elif name == 'FrameLabel': lines.append(f'\n## frame {frame} label {tb[:-1].decode("latin-1")!r}')
        elif name == 'DoAction':
            lines.append(f'\n## {ctx} frame {frame} DoAction'); lines.append(avm1.decompile(tb))
        elif name == 'DoInitAction':
            lines.append(f'\n## {ctx} DoInitAction sprite {int.from_bytes(tb[:2],"little")}'); lines.append(avm1.decompile(tb[2:]))
        elif name == 'PlaceObject2':
            po = swfraw.place_object2(tb)
            desc = f'depth {po["depth"]}' + (f' id {po["id"]}' if 'id' in po else '') + (f' name {po["name"]!r}' if 'name' in po else '')
            if 'clipActions' in po:
                for ev, key, chunk in po['clipActions']:
                    evs = [n for b, n in swfraw.CLIP_EVENTS.items() if ev & b]
                    lines.append(f'\n## {ctx} frame {frame} PlaceObject2 {desc} onClipEvent({"+".join(evs)}{" key=" + str(key) if key is not None else ""})')
                    lines.append(avm1.decompile(chunk))
        elif name == 'DefineButton2':
            bid, recs, acts = swfraw.button2(tb)
            for cond, chunk in acts:
                conds = [n for b, n in swfraw.BUTTON_CONDS.items() if cond & b]
                lines.append(f'\n## button {bid} on({"+".join(conds)} cond=0x{cond:x})'); lines.append(avm1.decompile(chunk))
        elif name == 'DefineSprite':
            sid, fc, stags = swfraw.sprite_tags(tb)
            sub = [f'# sprite {sid}: {fc} frames']
            walk(stags, f'sprite{sid}', sub)
            if len(sub) > 1: sprites[sid] = sub
walk(list(swfraw.read_tags(body, pos)), 'main', lines)
(OUT / 'main.txt').write_text('\n'.join(lines))
for sid, sub in sprites.items(): (OUT / f'sprite{sid}.txt').write_text('\n'.join(sub))
print('main lines', len(lines), 'sprites with code', len(sprites))
