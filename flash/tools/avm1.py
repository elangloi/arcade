"""AVM1 (ActionScript 1/2) bytecode -> readable pseudo-JavaScript.

Stack-machine simulation turns pushes/ops into expressions; control flow comes out as
labels + `if (...) goto` / `goto`, which is enough to read a small game's logic.
"""
import struct
from swfraw import Reader

SIMPLE = {
    0x04: 'nextFrame()', 0x05: 'prevFrame()', 0x06: 'play()', 0x07: 'stop()', 0x08: 'toggleQuality()',
    0x09: 'stopAllSounds()', 0x28: 'stopDrag()',
}
BINOPS = {0x0A: '+', 0x0B: '-', 0x0C: '*', 0x0D: '/', 0x0E: '==', 0x0F: '<', 0x10: '&&', 0x11: '||',
          0x13: 'eq', 0x21: 'add', 0x29: 'lt', 0x3F: '%', 0x47: '+', 0x48: '<', 0x49: '==', 0x60: '&', 0x61: '|',
          0x62: '^', 0x63: '<<', 0x64: '>>', 0x65: '>>>', 0x66: '===', 0x67: '>', 0x68: 'gt', 0x54: 'instanceof'}
UNOPS = {0x12: '!', 0x4A: 'Number', 0x4B: 'String', 0x44: 'typeof', 0x14: 'length', 0x31: 'mblength',
         0x32: 'ord', 0x33: 'chr', 0x36: 'mbord', 0x37: 'mbchr', 0x30: 'random', 0x50: '++', 0x51: '--',
         0x45: 'targetPath', 0x2B: 'cast'}
PROPS = ['_x', '_y', '_xscale', '_yscale', '_currentframe', '_totalframes', '_alpha', '_visible', '_width',
         '_height', '_rotation', '_target', '_framesloaded', '_name', '_droptarget', '_url', '_highquality',
         '_focusrect', '_soundbuftime', '_quality', '_xmouse', '_ymouse']


def prop_name(p):
    try:
        n = int(float(p))
        return PROPS[n] if 0 <= n < len(PROPS) else str(n)
    except ValueError:
        return p


def fmt_num(v):
    if isinstance(v, float) and v.is_integer() and abs(v) < 1e15:
        return str(int(v))
    return repr(v)


class Decompiler:
    def __init__(self, consts=None):
        self.consts = consts or []
        self.out = []

    # ---- parsing
    def parse_actions(self, data):
        """Return list of (offset, code, payload) up to end of data."""
        r = Reader(data); acts = []
        while r.p < len(data):
            off = r.p; code = r.u8()
            if code == 0: acts.append((off, 0, b'')); break
            payload = b''
            if code >= 0x80:
                ln = r.u16(); payload = r.bytes(ln)
            acts.append((off, code, payload))
        return acts

    def push_values(self, payload):
        r = Reader(payload); vals = []
        while r.p < len(payload):
            t = r.u8()
            if t == 0: vals.append(repr(r.string()))
            elif t == 1: vals.append(fmt_num(r.f32()))
            elif t == 2: vals.append('null')
            elif t == 3: vals.append('undefined')
            elif t == 4: vals.append(f'r{r.u8()}')
            elif t == 5: vals.append('true' if r.u8() else 'false')
            elif t == 6: vals.append(fmt_num(r.f64()))
            elif t == 7: vals.append(str(struct.unpack('<i', r.bytes(4))[0]))
            elif t == 8: i = r.u8(); vals.append(repr(self.consts[i]) if i < len(self.consts) else f'c{i}')
            elif t == 9: i = r.u16(); vals.append(repr(self.consts[i]) if i < len(self.consts) else f'c{i}')
            else: vals.append(f'?type{t}')
        return vals

    # ---- decompiling
    def decompile(self, data, indent=0, title=None):
        return self.run(self.parse_actions(data), indent)

    def run(self, acts, indent=0, stack=None):
        targets = {}
        for off, code, pl in acts:
            if code in (0x99, 0x9D):
                rel = struct.unpack('<h', pl[:2])[0]
                # jump target is relative to the end of this action (1 + 2 + len)
                t = off + 3 + len(pl) + rel; targets[t] = targets.get(t, 0) + 1
        lines = []
        pad = '  ' * indent
        stack = [] if stack is None else stack
        regs = {}

        def pop():
            return stack.pop() if stack else '?'

        def emit(s):
            lines.append(pad + s)

        def unq(s):  # strip quotes from string literal used as a name
            if len(s) >= 2 and s[0] in '\'"' and s[-1] == s[0]:
                return s[1:-1]
            return None

        def name_of(s):
            n = unq(s)
            return n if n is not None and n.replace('_', 'a').replace('.', 'a').replace('$', 'a').isalnum() else f'[{s}]'

        def member(obj, m):
            n = unq(m)
            if n is not None and (n.replace('_', 'a').replace('$', 'a').isalnum()):
                return f'{obj}.{n}'
            return f'{obj}[{m}]'

        i = 0
        while i < len(acts):
            off, code, pl = acts[i]
            i += 1
            if targets.get(off):
                lines.append(f'{pad[:-2] if indent else ""}L{off}:')
            if code == 0:
                break
            if code == 0x4C:
                # short-circuit `a && b` / `a || b`: dup, [not], if -> L, pop, <b>, L:
                j = i; neg = False
                if j < len(acts) and acts[j][1] == 0x12: neg = True; j += 1
                if j + 1 < len(acts) and acts[j][1] == 0x9D and acts[j + 1][1] == 0x17:
                    o2, _, p2 = acts[j]; target = o2 + 3 + len(p2) + struct.unpack('<h', p2[:2])[0]
                    m = next((k for k in range(j + 2, len(acts)) if acts[k][0] == target), None)
                    if m is not None:
                        a = pop()
                        sub = Decompiler(self.consts); sub_lines = sub.run(acts[j + 2:m], indent, [])
                        lines.extend(l for l in sub_lines if not l.strip().startswith('/* leftover stack'))
                        b = sub.stack_left[0] if len(sub.stack_left) == 1 else '?'
                        stack.append(f'({a} {"&&" if neg else "||"} {b})')
                        targets[target] -= 1
                        i = m; continue
            if code in SIMPLE:
                emit(SIMPLE[code]); continue
            if code == 0x96:  # push
                stack.extend(self.push_values(pl)); continue
            if code == 0x88:  # constant pool
                r = Reader(pl); n = r.u16(); self.consts = [r.string() for _ in range(n)]; continue
            if code == 0x17: emit(f'{pop()};' if stack else 'pop'); continue
            if code == 0x4C: v = pop(); stack += [v, v]; continue
            if code == 0x4D: a = pop(); b = pop(); stack += [a, b]; continue
            if code == 0x87:  # store register
                rn = pl[0]; v = stack[-1] if stack else '?'; emit(f'r{rn} = {v};'); continue
            if code in BINOPS:
                b = pop(); a = pop(); stack.append(f'({a} {BINOPS[code]} {b})'); continue
            if code in UNOPS:
                a = pop(); op = UNOPS[code]
                stack.append(f'{op}{a}' if op in ('!', '++', '--') else f'{op}({a})'); continue
            if code == 0x1C: stack.append(name_of(pop())); continue                  # get variable
            if code == 0x1D: v = pop(); n = pop(); emit(f'{name_of(n)} = {v};'); continue  # set variable
            if code == 0x3C: v = pop(); n = pop(); emit(f'var {name_of(n)} = {v};'); continue
            if code == 0x41: n = pop(); emit(f'var {name_of(n)};'); continue
            if code == 0x4E: m = pop(); o = pop(); stack.append(member(o, m)); continue
            if code == 0x4F: v = pop(); m = pop(); o = pop(); emit(f'{member(o, m)} = {v};'); continue
            if code == 0x22:
                p = pop(); t = pop(); pn = prop_name(p)
                stack.append(f'{t}.{pn}' if pn.startswith('_') else f'getProperty({t}, {pn})'); continue
            if code == 0x23:
                v = pop(); p = pop(); t = pop(); pn = prop_name(p)
                emit(f'{t}.{pn} = {v};' if pn.startswith('_') else f'setProperty({t}, {pn}, {v});'); continue
            if code == 0x3D:  # call function
                fn = pop(); n = int(float(pop())); args = [pop() for _ in range(n)]
                stack.append(f'{name_of(fn)}({", ".join(args)})'); continue
            if code == 0x52:  # call method
                m = pop(); o = pop(); n = int(float(pop())); args = [pop() for _ in range(n)]
                mn = unq(m)
                call = f'{o}({", ".join(args)})' if mn in (None, '') and m in ("''", '""', 'undefined') else f'{member(o, m)}({", ".join(args)})'
                stack.append(call); continue
            if code == 0x40:  # new object
                cls = pop(); n = int(float(pop())); args = [pop() for _ in range(n)]
                stack.append(f'new {name_of(cls)}({", ".join(args)})'); continue
            if code == 0x53:  # new method
                m = pop(); o = pop(); n = int(float(pop())); args = [pop() for _ in range(n)]
                stack.append(f'new {member(o, m)}({", ".join(args)})'); continue
            if code == 0x42:  # init array
                n = int(float(pop())); items = [pop() for _ in range(n)]; stack.append('[' + ', '.join(items) + ']'); continue
            if code == 0x43:  # init object
                n = int(float(pop())); items = []
                for _ in range(n):
                    v = pop(); k = pop(); items.append(f'{unq(k) or k}: {v}')
                stack.append('{' + ', '.join(items) + '}'); continue
            if code == 0x3E: emit(f'return {pop()};'); continue
            if code == 0x26: emit(f'trace({pop()});'); continue
            if code == 0x81: emit(f'gotoAndStop({struct.unpack("<H", pl[:2])[0] + 1});'); continue
            if code == 0x8C: emit(f'gotoFrame({pl[:-1].decode("latin-1")!r});'); continue
            if code == 0x9F:
                flags = pl[0]; f = pop(); emit(f'{"gotoAndPlay" if flags & 1 else "gotoAndStop"}({f});'); continue
            if code == 0x8B: emit(f'tellTarget({pl[:-1].decode("latin-1")!r});'); continue
            if code == 0x20: emit(f'tellTarget({pop()});'); continue
            if code == 0x83:
                r = Reader(pl); u = r.string(); t = r.string(); emit(f'getURL({u!r}, {t!r});'); continue
            if code == 0x9A: t = pop(); u = pop(); emit(f'getURL2({u}, {t}, flags={pl[0]});'); continue
            if code == 0x24: d = pop(); t = pop(); s = pop(); emit(f'duplicateMovieClip({s}, {t}, {d});'); continue
            if code == 0x25: emit(f'removeMovieClip({pop()});'); continue
            if code == 0x27:
                t = pop(); lock = pop(); c = pop()
                emit(f'startDrag({t}, lock={lock}, constrain={c});'); continue
            if code == 0x3A: m = pop(); o = pop(); emit(f'delete {member(o, m)};'); continue
            if code == 0x3B: emit(f'delete {pop()};'); continue
            if code == 0x34: stack.append('getTimer()'); continue
            if code == 0x46: emit(f'enumerate({pop()});'); stack.append('enum'); continue
            if code == 0x55: emit(f'enumerate2({pop()});'); stack.append('enum'); continue
            if code == 0x15: c = pop(); idx = pop(); s = pop(); stack.append(f'substring({s}, {idx}, {c})'); continue
            if code == 0x35: c = pop(); idx = pop(); s = pop(); stack.append(f'mbsubstring({s}, {idx}, {c})'); continue
            if code == 0x99:
                rel = struct.unpack('<h', pl[:2])[0]; emit(f'goto L{off + 3 + len(pl) + rel};'); continue
            if code == 0x9D:
                rel = struct.unpack('<h', pl[:2])[0]; c = pop(); emit(f'if ({c}) goto L{off + 3 + len(pl) + rel};'); continue
            if code == 0x9E: emit(f'call({pop()});'); continue
            if code == 0x8A:  # wait for frame
                continue
            if code == 0x8D: pop(); continue
            if code == 0x94:  # with
                size = struct.unpack('<H', pl[:2])[0]; o = pop()
                emit(f'with ({o}) {{')
                body = acts_bytes(acts, i, size)
                sub = Decompiler(self.consts); sub.decompile(body, indent + 1); lines.extend(sub.out)
                emit('}')
                i = skip_bytes(acts, i, size); continue
            if code in (0x9B, 0x8E):  # define function / function2
                r = Reader(pl); name = r.string(); nparams = r.u16()
                params = []
                if code == 0x8E:
                    regcount = r.u8(); flags = r.u16()
                    for _ in range(nparams):
                        reg = r.u8(); pn = r.string(); params.append(f'{pn}' + (f'/*r{reg}*/' if reg else ''))
                    preload = []
                    if flags & 0x01: preload.append('this')
                    if flags & 0x04: preload.append('arguments')
                    if flags & 0x10: preload.append('super')
                    if flags & 0x40: preload.append('_root')
                    if flags & 0x80: preload.append('_parent')
                    if flags & 0x100: preload.append('_global')
                    # registers 1.. are assigned in that order
                    regmap = {k + 1: v for k, v in enumerate(preload)}
                else:
                    for _ in range(nparams): params.append(r.string())
                    regmap = {}
                size = r.u16()
                body = acts_bytes(acts, i, size)
                sub = Decompiler(self.consts)
                sub.decompile(body, indent + 1)
                text = '\n'.join(sub.out)
                for rn, rv in regmap.items():
                    text = text.replace(f'r{rn}', rv)
                header = f'function {name}({", ".join(params)}) {{' if name else f'function({", ".join(params)}) {{'
                if name:
                    emit(header); lines.append(text) if text else None; emit('}')
                else:
                    stack.append(header + '\n' + text + '\n' + pad + '}')
                i = skip_bytes(acts, i, size); continue
            if code == 0x8F:  # try
                emit('/* try block (not decoded) */'); continue
            if code == 0x69: b = pop(); a = pop(); emit(f'{a} extends {b};'); continue
            if code == 0x2A: emit(f'throw {pop()};'); continue
            emit(f'/* op 0x{code:02x} {pl.hex()} */')
        self.stack_left = list(stack)
        if stack:
            emit('/* leftover stack: ' + ' | '.join(stack) + ' */')
        self.out = lines
        return lines


def acts_bytes(acts, i, size):
    """Return raw bytes of the `size` bytes of actions starting at acts[i]."""
    start = acts[i][0] if i < len(acts) else 0
    # reconstruct from the payloads
    out = b''
    total = 0
    j = i
    while j < len(acts) and total < size:
        off, code, pl = acts[j]
        chunk = bytes([code]) + (struct.pack('<H', len(pl)) + pl if code >= 0x80 else b'')
        out += chunk; total += len(chunk); j += 1
    return out


def skip_bytes(acts, i, size):
    total = 0; j = i
    while j < len(acts) and total < size:
        off, code, pl = acts[j]
        total += 1 + (2 + len(pl) if code >= 0x80 else 0); j += 1
    return j


def decompile(data, indent=0):
    d = Decompiler(); d.decompile(data, indent); return '\n'.join(d.out)
