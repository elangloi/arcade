"""Extract bitmaps, palettes and sounds from the ProjectorRays chunk dumps.

Usage:  uv run python extract.py [castname ...]

Reads  ../decompiled/<cast>/chunks/*  and writes
       ../assets/<cast>/<member>_<name>.png   (RGBA, white left opaque)
       ../assets/<cast>/manifest.json         (geometry + regpoints + palette)
       ../assets/<cast>/snd/<name>.<ext>
"""
import json
import re
import struct
import sys
import collections
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent / "drxtract"))
from drxtract.palettes.systemMac import SYSTEM_MAC_256COLORS_PALETTE
from drxtract.palettes.systemWin import SYSTEM_WINDOWS_256COLORS_PALETTE
from drxtract.palettes.systemWinDir4 import SYSTEM_WINDOWS_DIR4_256COLORS_PALETTE
from drxtract.palettes.grayscale import GRAYSCALE_256COLORS_PALETTE
from drxtract.palettes.rainbow import RAINBOW_256COLORS_PALETTE

ROOT = Path(__file__).resolve().parent.parent
DEC = ROOT / "decompiled"
OUT = ROOT / "assets"

TYPES = {1: 'bitmap', 2: 'filmloop', 3: 'text', 4: 'palette', 5: 'picture', 6: 'sound',
         7: 'button', 8: 'shape', 9: 'movie', 10: 'video', 11: 'script', 12: 'rte', 15: 'xtra'}


def bgr_flat_to_rgb(flat):
    return [(flat[i + 2], flat[i + 1], flat[i]) for i in range(0, len(flat), 4)]


BUILTIN = {  # id after "clutId - 1" adjustment
    -1: bgr_flat_to_rgb(SYSTEM_MAC_256COLORS_PALETTE),
    -102: bgr_flat_to_rgb(SYSTEM_WINDOWS_256COLORS_PALETTE),
    -101: bgr_flat_to_rgb(SYSTEM_WINDOWS_DIR4_256COLORS_PALETTE),
    -3: bgr_flat_to_rgb(GRAYSCALE_256COLORS_PALETTE),
    -2: bgr_flat_to_rgb(RAINBOW_256COLORS_PALETTE),
}
BUILTIN_NAMES = {-1: 'systemMac', -102: 'systemWin', -101: 'systemWinDir4', -3: 'grayscale', -2: 'rainbow'}


def load_json(p):
    txt = Path(p).read_text(errors='replace')
    txt = re.sub(r'\\x[0-9a-fA-F]{2}', '', txt)
    return json.loads(txt)


def parse_clut(b):
    n = len(b) // 6
    return [(b[i * 6], b[i * 6 + 2], b[i * 6 + 4]) for i in range(n)]


def rle_decode(data):
    out = bytearray()
    i = 0
    n = len(data)
    while i < n:
        v = data[i]
        i += 1
        if v & 0x80:
            run = 257 - v
            if i >= n:
                break
            out.extend(bytes([data[i]]) * run)
            i += 1
        else:
            run = v + 1
            out.extend(data[i:i + run])
            i += run
    return bytes(out)


def decode_bitmap(bitd, width, height, pitch, bpp, palette):
    """Return an RGBA PIL image."""
    expected = pitch * height
    raw = bitd if len(bitd) == expected else rle_decode(bitd)
    if len(raw) < expected:
        raw = raw + bytes(expected - len(raw))
    img = Image.new("RGBA", (width, height))
    px = img.load()
    for y in range(height):
        row = raw[y * pitch:(y + 1) * pitch]
        if bpp == 8:
            for x in range(width):
                r, g, b = palette[row[x]] if row[x] < len(palette) else (255, 0, 255)
                px[x, y] = (r, g, b, 255)
        elif bpp == 1:
            for x in range(width):
                bit = (row[x >> 3] >> (7 - (x & 7))) & 1
                v = 0 if bit else 255
                px[x, y] = (v, v, v, 255)
        elif bpp == 2:
            for x in range(width):
                idx = (row[x >> 2] >> (6 - 2 * (x & 3))) & 0x3
                r, g, b = palette[idx] if palette and idx < len(palette) else (255 - idx * 85,) * 3
                px[x, y] = (r, g, b, 255)
        elif bpp == 4:
            for x in range(width):
                idx = (row[x >> 1] >> (4 if (x & 1) == 0 else 0)) & 0xF
                r, g, b = palette[idx] if idx < len(palette) else (255, 0, 255)
                px[x, y] = (r, g, b, 255)
        elif bpp == 16:
            # two planes per row: high bytes then low bytes
            for x in range(width):
                v = (row[x] << 8) | row[width + x]
                r = ((v >> 10) & 0x1F) << 3
                g = ((v >> 5) & 0x1F) << 3
                b = (v & 0x1F) << 3
                px[x, y] = (r, g, b, 255)
        elif bpp == 32:
            # four planes per row: A R G B
            for x in range(width):
                a = row[x]
                r = row[width + x]
                g = row[2 * width + x]
                b = row[3 * width + x]
                px[x, y] = (r, g, b, 255 - a if a else 255)
        else:
            raise ValueError(f"unsupported bpp {bpp}")
    return img


def key_table(chunks):
    key = load_json(next(chunks.glob("KEY_-*.json")))["entries"]
    owned = collections.defaultdict(dict)
    for e in key:
        if e["sectionID"]:
            owned[e["castID"]][e["fourCC"].strip()] = e["sectionID"]
    return owned


def cast_tables(castdir):
    """Yield (castname, CAS_ member id list) for every cast in this file."""
    chunks = castdir / "chunks"
    owned = key_table(chunks)
    mcsl = list(chunks.glob("MCsL-*.json"))
    if mcsl:
        for e in load_json(mcsl[0])["entries"]:
            if e["filePath"]:
                continue  # external cast, extracted from its own file
            cas_id = owned.get(e["id"], {}).get("CAS*")
            if not cas_id:
                continue
            yield e["name"], load_json(chunks / f"CAS_-{cas_id}.json")["memberIDs"], e.get("minMember", 1) or 1
    else:
        yield castdir.name, load_json(next(chunks.glob("CAS_-*.json")))["memberIDs"], 1


def cast_members(castdir, cas, min_member=1):
    """Member numbers are CAS* index + minMember - 1 (casts don't have to start at member 1)."""
    chunks = castdir / "chunks"
    owned = key_table(chunks)
    members = {}
    for i, cid in enumerate(cas):
        if not cid:
            continue
        b = (chunks / f"CASt-{cid}.bin").read_bytes()
        j = load_json(chunks / f"CASt-{cid}.json")
        typ, infoLen, specLen = struct.unpack('>III', b[:12])
        spec = b[12 + infoLen:12 + infoLen + specLen]
        num = i + min_member
        members[num] = dict(num=num, cid=cid, type=TYPES.get(typ, typ),
                            name=j["info"]["name"], spec=spec, owned=owned.get(cid, {}))
    return chunks, members


def safe(name):
    return re.sub(r'[^A-Za-z0-9._-]+', '_', name).strip('_') or 'unnamed'


def extract_cast(castdir, castname, cas, min_member=1, overrides=None):
    overrides = overrides or {}
    chunks, members = cast_members(castdir, cas, min_member)
    outdir = OUT / castname
    outdir.mkdir(parents=True, exist_ok=True)
    (outdir / "snd").mkdir(exist_ok=True)

    palettes = {}
    for m in members.values():
        if m['type'] == 'palette' and 'CLUT' in m['owned']:
            palettes[m['num']] = parse_clut((chunks / f"CLUT-{m['owned']['CLUT']}.bin").read_bytes())

    # Palette refs are member numbers as authored; casts whose first member isn't #1 store them shifted.
    # Detect the shift as the smallest offset that maps every dangling ref onto a real palette member.
    dangling = set()
    for m in members.values():
        if m['type'] == 'bitmap' and len(m['spec']) >= 28 and m['spec'][23] in (4, 8):
            lib, mem = struct.unpack('>hh', m['spec'][24:28])
            if mem > 0 and mem not in palettes:
                dangling.add(mem)
    pal_offset = 0
    if dangling and palettes:
        for k in range(1, 600):
            if all((d - k) in palettes for d in dangling):
                pal_offset = k
                break
        if pal_offset:
            print(f"  {castname}: palette refs shifted by +{pal_offset} ({sorted(dangling)})")
        else:
            print(f"  {castname}: could not resolve palette refs {sorted(dangling)}; palettes {sorted(palettes)}")

    manifest = {"cast": castname, "palettes": {str(k): members[k]['name'] for k in palettes}, "members": []}
    stats = collections.Counter()
    for m in members.values():
        entry = dict(num=m['num'], type=m['type'], name=m['name'])
        if m['type'] == 'bitmap' and 'BITD' in m['owned']:
            s = m['spec']
            pitch = struct.unpack('>H', s[0:2])[0] & 0x0FFF
            top, left, bottom, right = struct.unpack('>hhhh', s[2:10])
            regY, regX = struct.unpack('>hh', s[18:22])
            bpp = s[23] if len(s) > 23 else 1
            palref = None
            if len(s) >= 28:
                lib, mem = struct.unpack('>hh', s[24:28])
                palref = mem if mem > 0 else mem - 1
                if palref > 0 and palref not in palettes and pal_offset:
                    palref -= pal_offset
            width, height = right - left, bottom - top
            if m['num'] in overrides:
                palref = overrides[m['num']]
            if bpp in (8, 4, 2):
                if palref is not None and palref > 0 and palref in palettes:
                    pal = palettes[palref]
                    palname = members[palref]['name']
                elif palref is not None and palref in BUILTIN:
                    pal = BUILTIN[palref]
                    palname = BUILTIN_NAMES[palref]
                else:
                    pal = BUILTIN[-1]
                    palname = f"UNRESOLVED({palref})->systemMac"
                    stats['unresolved_palette'] += 1
            else:
                pal, palname = None, None
            bitd = (chunks / f"BITD-{m['owned']['BITD']}.bin").read_bytes()
            try:
                img = decode_bitmap(bitd, width, height, pitch, bpp, pal)
            except Exception as e:  # keep going, note failure
                entry['error'] = str(e)
                stats['errors'] += 1
                manifest['members'].append(entry)
                continue
            fn = f"{m['num']:03d}_{safe(m['name'])}.png"
            img.save(outdir / fn)
            entry.update(file=fn, width=width, height=height, regX=regX, regY=regY, bpp=bpp,
                         palette=palname, bitd=m['owned']['BITD'])
            stats[f'bmp{bpp}'] += 1
        elif m['type'] == 'bitmap' and 'ediM' in m['owned']:
            # JPEG-compressed bitmap (Shockwave "jpeg" cast compression) + optional RLE alpha plane
            s = m['spec']
            top, left, bottom, right = struct.unpack('>hhhh', s[2:10])
            regY, regX = struct.unpack('>hh', s[18:22])
            width, height = right - left, bottom - top
            import io
            try:
                img = Image.open(io.BytesIO((chunks / f"ediM-{m['owned']['ediM']}.bin").read_bytes())).convert("RGBA")
                if 'ALFA' in m['owned']:
                    a = rle_decode((chunks / f"ALFA-{m['owned']['ALFA']}.bin").read_bytes())
                    a = a[:width * height]
                    # a constant alpha plane (all 0 or all 255) carries no information; Director drew these opaque
                    if len(a) >= width * height and a.count(a[0:1]) != len(a):
                        img.putalpha(Image.frombytes("L", (width, height), a))
            except Exception as e:  # keep going, note failure
                entry['error'] = str(e)
                stats['errors'] += 1
                manifest['members'].append(entry)
                continue
            fn = f"{m['num']:03d}_{safe(m['name'])}.png"
            img.save(outdir / fn)
            entry.update(file=fn, width=width, height=height, regX=regX, regY=regY, bpp=32, palette='jpeg')
            stats['jpeg'] += 1
        elif m['type'] == 'sound' and 'snd' in m['owned']:
            snd = (chunks / f"snd -{m['owned']['snd']}.bin").read_bytes()
            ext = 'mp3' if snd[:3] == b'ID3' or (len(snd) > 1 and snd[0] == 0xFF and (snd[1] & 0xE0) == 0xE0) else 'snd'
            fn = f"{m['num']:03d}_{safe(m['name'])}.{ext}"
            (outdir / "snd" / fn).write_bytes(snd)
            entry.update(file=f"snd/{fn}", bytes=len(snd))
            stats['snd'] += 1
        manifest['members'].append(entry)
    (outdir / "manifest.json").write_text(json.dumps(manifest, indent=1))
    print(f"{castname}: {len(members)} members {dict(stats)}")


OVERRIDES = {  # cast -> {member: palette member}  (for dangling palette refs, chosen by eye)
}

if __name__ == "__main__":
    names = sys.argv[1:]
    for castdir in sorted(DEC.glob("*/")):
        if not (castdir / "chunks").exists():
            continue
        for castname, cas, min_member in cast_tables(castdir):
            if names and castname not in names:
                continue
            extract_cast(castdir, castname, cas, min_member, OVERRIDES.get(castname))
