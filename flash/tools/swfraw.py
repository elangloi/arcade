"""Minimal raw SWF tag reader: header, tag list (recursing into DefineSprite), and the
places ActionScript bytecode hides (DoAction, DoInitAction, DefineButton2, PlaceObject2
clip actions)."""
import struct, zlib
from pathlib import Path

from common import need_swf

TAG_NAMES = {0: 'End', 1: 'ShowFrame', 2: 'DefineShape', 4: 'PlaceObject', 5: 'RemoveObject', 6: 'DefineBits',
             7: 'DefineButton', 8: 'JPEGTables', 9: 'SetBackgroundColor', 10: 'DefineFont', 11: 'DefineText',
             12: 'DoAction', 13: 'DefineFontInfo', 14: 'DefineSound', 15: 'StartSound', 17: 'DefineButtonSound',
             18: 'SoundStreamHead', 19: 'SoundStreamBlock', 20: 'DefineBitsLossless', 21: 'DefineBitsJPEG2',
             22: 'DefineShape2', 24: 'Protect', 26: 'PlaceObject2', 28: 'RemoveObject2', 32: 'DefineShape3',
             33: 'DefineText2', 34: 'DefineButton2', 35: 'DefineBitsJPEG3', 36: 'DefineBitsLossless2',
             37: 'DefineEditText', 39: 'DefineSprite', 43: 'FrameLabel', 45: 'SoundStreamHead2',
             46: 'DefineMorphShape', 48: 'DefineFont2', 56: 'ExportAssets', 59: 'DoInitAction', 69: 'FileAttributes',
             70: 'PlaceObject3', 75: 'DefineFont3', 88: 'DefineFontName'}


class Reader:
    def __init__(self, data, pos=0):
        self.d = data; self.p = pos; self.bitbuf = 0; self.bitpos = 0
    def u8(self): v = self.d[self.p]; self.p += 1; return v
    def u16(self): v = struct.unpack_from('<H', self.d, self.p)[0]; self.p += 2; return v
    def s16(self): v = struct.unpack_from('<h', self.d, self.p)[0]; self.p += 2; return v
    def u32(self): v = struct.unpack_from('<I', self.d, self.p)[0]; self.p += 4; return v
    def f32(self): v = struct.unpack_from('<f', self.d, self.p)[0]; self.p += 4; return v
    def f64(self):  # SWF stores doubles with the 32-bit words swapped
        lo, hi = struct.unpack_from('<II', self.d, self.p); self.p += 8
        return struct.unpack('<d', struct.pack('<II', hi, lo))[0]
    def string(self):
        e = self.d.index(b'\0', self.p); s = self.d[self.p:e].decode('latin-1'); self.p = e + 1; return s
    def bytes(self, n): v = self.d[self.p:self.p + n]; self.p += n; return v
    # bit reading
    def align(self): self.bitpos = 0
    def ub(self, n):
        v = 0
        for _ in range(n):
            if self.bitpos == 0:
                self.bitbuf = self.d[self.p]; self.p += 1; self.bitpos = 8
            self.bitpos -= 1
            v = (v << 1) | ((self.bitbuf >> self.bitpos) & 1)
        return v
    def sb(self, n):
        v = self.ub(n)
        if n and v & (1 << (n - 1)): v -= 1 << n
        return v
    def rect(self):
        self.align(); n = self.ub(5); r = (self.sb(n), self.sb(n), self.sb(n), self.sb(n)); self.align(); return r
    def matrix(self):
        self.align()
        m = {'sx': 1.0, 'sy': 1.0, 'r0': 0.0, 'r1': 0.0, 'tx': 0, 'ty': 0}
        if self.ub(1):
            n = self.ub(5); m['sx'] = self.sb(n) / 65536; m['sy'] = self.sb(n) / 65536
        if self.ub(1):
            n = self.ub(5); m['r0'] = self.sb(n) / 65536; m['r1'] = self.sb(n) / 65536
        n = self.ub(5); m['tx'] = self.sb(n); m['ty'] = self.sb(n)
        self.align(); return m
    def cxform(self, alpha=True):
        self.align()
        has_add = self.ub(1); has_mul = self.ub(1); n = self.ub(4)
        k = 4 if alpha else 3
        mul = [self.sb(n) / 256 for _ in range(k)] if has_mul else [1.0] * k
        add = [self.sb(n) for _ in range(k)] if has_add else [0] * k
        self.align(); return {'mul': mul, 'add': add}


def load_body(path=None):
    raw = (path or need_swf()).read_bytes()
    sig = raw[:3]
    body = zlib.decompress(raw[8:]) if sig == b'CWS' else raw[8:]
    r = Reader(body)
    frame_size = r.rect(); rate = r.u16() / 256; count = r.u16()
    return body, r.p, {'frame_size': frame_size, 'rate': rate, 'frames': count, 'version': raw[3]}


def read_tags(data, pos, end=None):
    """Yield (code, name, body_bytes) for tags starting at pos."""
    end = len(data) if end is None else end
    r = Reader(data, pos)
    while r.p < end:
        hdr = r.u16(); code = hdr >> 6; length = hdr & 0x3F
        if length == 0x3F: length = r.u32()
        body = r.bytes(length)
        yield code, TAG_NAMES.get(code, f'Tag{code}'), body
        if code == 0: break


def sprite_tags(body):
    """DefineSprite body -> (id, frame_count, [(code, name, body)])"""
    r = Reader(body); sid = r.u16(); fc = r.u16()
    return sid, fc, list(read_tags(body, 4))


def button2(body):
    """DefineButton2 -> (id, records, [(cond_flags, action_bytes)])"""
    r = Reader(body); bid = r.u16(); flags = r.u8(); action_offset = r.u16()
    records = []
    while True:
        f = r.u8()
        if f == 0: break
        rec = {'flags': f, 'id': r.u16(), 'depth': r.u16(), 'matrix': r.matrix(), 'cxform': r.cxform()}
        records.append(rec)
    actions = []
    if action_offset:
        r.p = 2 + 1 + 2 + action_offset - 0 if False else r.p  # records end where actions begin
        while r.p < len(body):
            size = r.u16(); cond = r.u16()
            chunk = body[r.p: (r.p + size - 4) if size else len(body)]
            actions.append((cond, chunk))
            if size == 0: break
            r.p += size - 4
    return bid, records, actions


def place_object2(body, swf_version=6, v3=False):
    """PlaceObject2/3 -> dict with depth, id, matrix, name, ratio, clip actions [(event_flags, bytes)]"""
    r = Reader(body); flags = r.u8()
    flags2 = r.u8() if v3 else 0
    depth = r.u16()
    out = {'flags': flags, 'depth': depth}
    if flags2 & 0x08 or (flags2 & 0x10 and flags & 0x02): out['className'] = r.string()
    if flags & 0x02: out['id'] = r.u16()
    if flags & 0x04: out['matrix'] = r.matrix()
    if flags & 0x08: out['cxform'] = r.cxform()
    if flags & 0x10: out['ratio'] = r.u16()
    if flags & 0x20: out['name'] = r.string()
    if flags & 0x40: out['clipDepth'] = r.u16()
    if flags2 & 0x01:   # filter list: sizes by type (gradient/convolution filters are variable)
        n = r.u8(); names = []
        for _ in range(n):
            t = r.u8()
            if t == 0: r.p += 23; names.append('dropShadow')
            elif t == 1: r.p += 9; names.append('blur')
            elif t == 2: r.p += 15; names.append('glow')
            elif t == 3: r.p += 27; names.append('bevel')
            elif t == 4: nc = r.u8(); r.p += nc * 5 + 19; names.append('gradientGlow')
            elif t == 5: mx = r.u8(); my = r.u8(); r.p += 8 + mx * my * 4 + 5 + 1; names.append('convolution')
            elif t == 6: r.p += 80; names.append('colorMatrix')
            elif t == 7: nc = r.u8(); r.p += nc * 5 + 19; names.append('gradientBevel')
        out['filters'] = names
    if flags2 & 0x02: out['blend'] = r.u8()
    if flags2 & 0x04: r.u8()   # cache as bitmap
    if flags2 & 0x20: out['visible'] = r.u8()
    if flags2 & 0x40: r.u32()  # background colour
    if flags & 0x80:
        r.u16()  # reserved
        all_flags = r.u32() if swf_version >= 6 else r.u16()
        clips = []
        while True:
            ev = r.u32() if swf_version >= 6 else r.u16()
            if ev == 0: break
            size = r.u32()
            key = r.u8() if ev & 0x20000 else None
            chunk = body[r.p:r.p + size - (1 if key is not None else 0)]
            r.p += size - (1 if key is not None else 0)
            clips.append((ev, key, chunk))
        out['clipActions'] = clips
    return out


CLIP_EVENTS = {0x1: 'load', 0x2: 'enterFrame', 0x4: 'unload', 0x8: 'mouseMove', 0x10: 'mouseDown', 0x20: 'mouseUp',
               0x40: 'keyDown', 0x80: 'keyUp', 0x100: 'data', 0x200: 'initialize', 0x400: 'press', 0x800: 'release',
               0x1000: 'releaseOutside', 0x2000: 'rollOver', 0x4000: 'rollOut', 0x8000: 'dragOver', 0x10000: 'dragOut',
               0x20000: 'keyPress', 0x40000: 'construct'}
BUTTON_CONDS = {0x1: 'idleToOverUp', 0x2: 'overUpToIdle', 0x4: 'overUpToOverDown', 0x8: 'overDownToOverUp',
                0x10: 'overDownToOutDown', 0x20: 'outDownToOverDown', 0x40: 'outDownToIdle', 0x80: 'idleToOverDown',
                0x100: 'overDownToIdle'}
