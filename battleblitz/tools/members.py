"""Build ../assets/members.json: every cast member the runtime can reference, keyed by castLib number.

uv run python members.py

members.json = {
  "castLibs": {name: number},
  "casts": { "<num>": { "name": ..., "members": { "<memberNum>": {name, type, file, w, h, regX, regY} } } },
  "filmloops": { "<lib>:<mem>": {frames: [...], intervals: [...]} }
}
"""
import json, struct, re, collections
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from extract import load_json, key_table, cast_tables, cast_members, DEC, ROOT
from score import decode_score

ASSETS = ROOT / 'assets'

# castLib numbering = order in the movie's cast list (MCsL)
mcsl = load_json(next((DEC / 'battleblitz' / 'chunks').glob('MCsL-*.json')))['entries']
castlibs = {e['name']: i + 1 for i, e in enumerate(mcsl)}

out = {"castLibs": castlibs, "casts": {}, "filmloops": {}}
for castdir in sorted(DEC.glob('*/')):
    if not (castdir / 'chunks').exists():
        continue
    for castname, cas, min_member in cast_tables(castdir):
        num = castlibs.get(castname)
        if num is None:
            print('skip', castname)
            continue
        manifest_path = ASSETS / castname / 'manifest.json'
        manifest = json.load(open(manifest_path)) if manifest_path.exists() else {"members": []}
        by_num = {m['num']: m for m in manifest['members']}
        chunks, members = cast_members(castdir, cas, min_member)
        table = {}
        for m in members.values():
            e = {"name": m['name'], "type": m['type']}
            mm = by_num.get(m['num'], {})
            if mm.get('file'):
                e["file"] = f"{castname}/{mm['file']}"
            for k in ('width', 'height', 'regX', 'regY'):
                if k in mm:
                    e[{'width': 'w', 'height': 'h'}.get(k, k)] = mm[k]
            if m['type'] == 'filmloop' and 'SCVW' in m['owned']:
                frames, intervals = decode_score((chunks / f"SCVW-{m['owned']['SCVW']}.bin").read_bytes())
                spec = m['spec']
                top, left, bottom, right = struct.unpack('>hhhh', spec[:8])
                flags = struct.unpack('>I', spec[8:12])[0] if len(spec) >= 12 else 0
                out['filmloops'][f"{num}:{m['num']}"] = {"frames": frames, "intervals": intervals,
                                                          "rect": [left, top, right, bottom], "loop": not (flags & 0x20)}
                e["filmloop"] = True
            if m['type'] == 'text' and 'STXT' in m['owned']:
                b = (chunks / f"STXT-{m['owned']['STXT']}.bin").read_bytes()
                off, tlen = struct.unpack('>II', b[:8])
                e["text"] = b[off:off + tlen].decode('latin1')
            table[str(m['num'])] = e
        out['casts'][str(num)] = {"name": castname, "members": table}

(ASSETS / 'members.json').write_text(json.dumps(out, separators=(',', ':')))
print('casts', len(out['casts']), 'filmloops', len(out['filmloops']))
tc = collections.Counter(e['type'] for c in out['casts'].values() for e in c['members'].values())
print(dict(tc))
