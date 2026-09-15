"""Parse the Director 8 score (VWSC) + labels (VWLB) + film loops (SCVW) into JSON.

uv run python score.py            -> writes ../assets/score.json

Output:
  labels:    {name: frame}
  frames:    [ {script: [castLib, member] | null, sprites: {spriteNum: rec}} ]   (index 0 = frame 1)
             rec = [type, ink, castLib, member, locH, locV, width, height, blend, flags, rotation, stretch]
  intervals: [ {start, end, ch, behaviors: [[castLib, member, paramsText]]} ]
  filmloops: { "castLib:member": {frames: [...same as frames...] } }   (filled in by members.py)
"""
import struct, json, sys, re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHUNKS = ROOT / 'decompiled/battleblitz/chunks'

HEADER_CHANNELS = 6  # D6+: script, tempo, transition, sound2, sound1, palette


def parse_frames(inner):
    size, marker, frame_count, unk1, rec_size, chan_count, unk2 = struct.unpack('>iiihhhh', inner[:20])
    assert marker == 0x14, marker
    idx = 20
    cur = bytearray(chan_count * rec_size)
    frames = []
    while idx < size:
        fsz = struct.unpack('>h', inner[idx:idx + 2])[0]
        idx += 2
        rem = fsz - 2
        while rem > 0:
            dsz, doff = struct.unpack('>hH', inner[idx:idx + 4])
            idx += 4
            rem -= 4
            cur[doff:doff + dsz] = inner[idx:idx + dsz]
            idx += dsz
            rem -= dsz
        frames.append(bytes(cur))
    return rec_size, chan_count, frames


def decode_sprite(rec):
    typ, ink, fore, back, lib, mem = struct.unpack('>BBBBhH', rec[:8])
    locV, locH, h, w = struct.unpack('>hhhh', rec[12:20])
    colorcode, blend, flags = rec[20], rec[21], rec[22]
    rot = struct.unpack('>i', rec[28:32])[0] / 100.0 if len(rec) >= 32 else 0.0
    blend_pct = round((255 - blend) * 100 / 255)
    stretch = 1 if ink & 0x80 else 0   # without it Director shows the member at natural size
    return [typ, ink & 0x3F, lib, mem, locH, locV, w, h, blend_pct, flags, rot, stretch]


def decode_score(data):
    """data = wrapped VWSC/SCVW chunk bytes. Returns (frames, intervals)."""
    dataSize, marker, unk1, n1, n2, last = struct.unpack('>iiiiii', data[:24])
    assert marker == -3, marker
    idx = 24
    offs = [struct.unpack('>I', data[idx + 4 * i:idx + 4 * i + 4])[0] for i in range(n2)]
    base = idx + 4 * n2
    ent = lambda i: data[base + offs[i]:base + offs[i + 1]] if i + 1 < len(offs) else b''
    rec_size, chan_count, raw = parse_frames(ent(0))
    frames = []
    for fr in raw:
        f = {"script": None, "sprites": {}}
        hdr = fr[:rec_size]
        lib, mem = struct.unpack('>hH', hdr[:4])
        if mem:
            f["script"] = [lib, mem]
        for ch in range(HEADER_CHANNELS, chan_count):
            rec = fr[ch * rec_size:(ch + 1) * rec_size]
            if rec[6:8] != b'\0\0' or any(rec[:20]):
                f["sprites"][str(ch - HEADER_CHANNELS + 1)] = decode_sprite(rec)
        frames.append(f)
    intervals = []
    i = 2
    while i < len(offs) - 1:
        e = ent(i)
        if len(e) >= 44 and struct.unpack('>I', e[:4])[0] < 100000 and not all(32 <= c < 127 or c == 0 for c in e):
            start, end, _, _, ch = struct.unpack('>IIIII', e[:20])
            if 1 <= start <= end <= len(frames) + 1 and HEADER_CHANNELS <= ch < chan_count:
                behaviors = []
                nxt = ent(i + 1)
                if nxt and len(nxt) % 8 == 0 and not all(32 <= c < 127 or c == 0 for c in nxt):
                    for j in range(0, len(nxt), 8):
                        blib, bmem, pidx = struct.unpack('>hHI', nxt[j:j + 8])
                        params = ent(pidx).rstrip(b'\0').decode('latin1') if pidx else ''
                        behaviors.append([blib, bmem, params])
                    i += 1
                intervals.append({"start": start, "end": end, "ch": ch - HEADER_CHANNELS + 1, "behaviors": behaviors})
        i += 1
    return frames, intervals


def parse_labels():
    b = next(CHUNKS.glob('VWLB-*.bin')).read_bytes()
    n = struct.unpack('>H', b[:2])[0]
    entries = [struct.unpack('>HH', b[2 + i * 4:6 + i * 4]) for i in range(n + 1)]
    txt = b[2 + (n + 1) * 4:]
    labels = {}
    for i in range(n):
        f, o = entries[i]
        o2 = entries[i + 1][1]
        labels[txt[o:o2].decode('latin1')] = f
    return labels


if __name__ == '__main__':
    frames, intervals = decode_score(next(CHUNKS.glob('VWSC-*.bin')).read_bytes())
    labels = parse_labels()
    out = {"labels": labels, "frames": frames, "intervals": intervals, "filmloops": {}}
    (ROOT / 'assets/score.json').write_text(json.dumps(out, separators=(',', ':')))
    print('frames', len(frames), 'intervals', len(intervals), 'labels', len(labels))
    import collections
    types = collections.Counter()
    libs = collections.Counter()
    for f in frames:
        for s in f["sprites"].values():
            types[s[0]] += 1
            libs[s[2]] += 1
    print('sprite types', dict(types))
    print('castLibs', dict(libs))
    beh = collections.Counter((b[0], b[1]) for iv in intervals for b in iv["behaviors"])
    print('behaviors', dict(beh))
