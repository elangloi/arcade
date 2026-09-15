"""Survey CASt members in the decompiled casts: types, palettes, name patterns."""
import struct, glob, json, re, collections, sys
from pathlib import Path

DEC = Path(__file__).resolve().parent.parent / "decompiled"
TYPES = {1:'bitmap',2:'filmloop',3:'text',4:'palette',5:'picture',6:'sound',7:'button',8:'shape',9:'movie',10:'video',11:'script',12:'rte',15:'xtra'}

def load_json(p):
    txt = Path(p).read_text(errors='replace')
    txt = re.sub(r'\\x[0-9a-fA-F]{2}', '', txt)
    return json.loads(txt)

def parse_cast_member(b):
    typ, infoLen, specLen = struct.unpack('>III', b[:12])
    info = b[12:12+infoLen]; spec = b[12+infoLen:12+infoLen+specLen]
    name = ''
    if infoLen:
        dataOffset = struct.unpack('>I', info[:4])[0]
        # info has offset table; parse like ProjectorRays: after 20-byte header, uint16 count, uint32 offsets[count+1], then data
        # Simpler: use the JSON dump for name.
    return typ, info, spec

def members(castdir):
    chunks = Path(castdir) / "chunks"
    cas = load_json(next(chunks.glob("CAS_-*.json")))["memberIDs"]
    key = load_json(next(chunks.glob("KEY_-*.json")))["entries"]
    owned = collections.defaultdict(dict)
    for e in key:
        if e["sectionID"]:
            owned[e["castID"]][e["fourCC"].strip()] = e["sectionID"]
    out = []
    for i, cid in enumerate(cas):
        if not cid: continue
        b = (chunks / f"CASt-{cid}.bin").read_bytes()
        j = load_json(chunks / f"CASt-{cid}.json")
        typ, info, spec = parse_cast_member(b)
        out.append(dict(num=i+1, cid=cid, type=TYPES.get(typ, typ), name=j["info"]["name"], spec=spec, owned=owned.get(cid, {})))
    return out

if __name__ == "__main__":
    for castdir in sorted(DEC.glob("*/")):
        if not (castdir / "chunks").exists(): continue
        ms = members(castdir)
        tc = collections.Counter(m['type'] for m in ms)
        print(f"== {castdir.name}: {len(ms)} members {dict(tc)}")
        pals = [m for m in ms if m['type']=='palette']
        print("   palettes:", [(m['num'], m['name'], m['owned']) for m in pals])
        refs = collections.Counter()
        for m in ms:
            if m['type']=='bitmap' and len(m['spec'])>=28:
                lib, mem = struct.unpack('>hh', m['spec'][24:28]); refs[(m['spec'][23], lib, mem)] += 1
        print("   bitmap (bpp,lib,palmember) refs:", dict(refs))
        # 1-bit following 8-bit?
        if castdir.name == 'char_Robin':
            for m in ms[:40]: print("   ", m['num'], m['type'], m['name'], m['spec'][22:24].hex() if m['type']=='bitmap' else '', m['owned'])
