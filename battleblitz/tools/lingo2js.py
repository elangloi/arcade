"""Transpile ProjectorRays-decompiled Lingo (.ls) into ES modules.

uv run python lingo2js.py     -> writes ../web/game/classes.js

Handles the subset of Lingo used by Battle Blitz: parent scripts with `ancestor`
inheritance, behaviors, the movie script, lists/proplists, points/rects, case,
repeat loops, and the Director APIs the game touches. Runtime helpers live in
../web/runtime/lingo.js and ../web/runtime/director.js.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'decompiled/battleblitz/casts/Lingo'
OUT = ROOT / 'web/game/classes.js'

# ---------------------------------------------------------------- tokenizer

TOKEN_RE = re.compile(r'''
    (?P<ws>[ \t]+) |
    (?P<float>\d+\.\d+) |
    (?P<int>\d+) |
    (?P<string>"[^"\n]*") |
    (?P<symbol>\#[A-Za-z_][A-Za-z0-9_]*) |
    (?P<ident>[A-Za-z_][A-Za-z0-9_]*) |
    (?P<op><>|<=|>=|&&|[-+*/=<>&(),\[\]:.]) |
    (?P<other>.)
''', re.X)

KEYWORDS = {'if', 'then', 'else', 'end', 'case', 'of', 'otherwise', 'repeat', 'with', 'in', 'to', 'while',
            'down', 'exit', 'next', 'return', 'and', 'or', 'not', 'mod', 'the', 'me', 'contains', 'starts',
            'put', 'into', 'after', 'before', 'set', 'tell', 'on', 'property', 'global', 'VOID'}


class Tok:
    __slots__ = ('kind', 'val', 'col')

    def __init__(self, kind, val, col):
        self.kind, self.val, self.col = kind, val, col

    def __repr__(self):
        return f'{self.kind}:{self.val}'


def tokenize(line):
    toks = []
    for m in TOKEN_RE.finditer(line):
        k = m.lastgroup
        if k == 'ws':
            continue
        v = m.group()
        if k == 'ident' and v in KEYWORDS:
            k = 'kw'
        if k == 'other':
            raise SyntaxError(f'bad char {v!r} in: {line}')
        toks.append(Tok(k, v, m.start()))
    return toks


# ---------------------------------------------------------------- AST nodes (tuples)
# expressions:
#   ('num', value, isfloat) ('str', s) ('sym', name) ('void',) ('me',) ('id', name)
#   ('list', [exprs]) ('plist', [(keyExpr, valExpr)]) ('the', name) ('paren', e)
#   ('prop', obj, name) ('index', obj, idx) ('call', fnName, [args]) ('mcall', obj, name, [args])
#   ('bin', op, a, b) ('un', op, a)
# statements:
#   ('assign', lvalue, expr) ('expr', e) ('if', cond, block, elseBlock|None)
#   ('case', expr, [(labels|None, block)]) ('repeatwith', var, a, b, down, block)
#   ('repeatin', var, listExpr, block) ('repeatwhile', cond, block)
#   ('exitrepeat',) ('nextrepeat',) ('exit',) ('return', expr|None) ('settheprop', name, expr)
#   ('put', expr) ('tell', target, block)


class Parser:
    def __init__(self, lines):
        self.lines = lines  # list of (indent, tokens)
        self.i = 0

    # ---- statement level
    def peek_line(self):
        return self.lines[self.i] if self.i < len(self.lines) else None

    def parse_block(self, indent):
        """Parse statements with indentation > indent until a dedent/terminator."""
        stmts = []
        while self.i < len(self.lines):
            ind, toks = self.lines[self.i]
            if ind <= indent:
                break
            if self.is_terminator(toks):
                break
            stmts.append(self.parse_statement())
        return stmts

    @staticmethod
    def is_terminator(toks):
        if not toks:
            return False
        t = toks[0]
        if t.kind == 'kw' and t.val in ('end', 'else', 'otherwise'):
            return True
        if t.kind == 'kw' and t.val == 'end':
            return True
        # case label: "expr, expr:"  -> ends with ':'
        if toks[-1].kind == 'op' and toks[-1].val == ':' and not (t.kind == 'kw' and t.val in ('put', 'set')):
            return True
        return False

    def parse_statement(self):
        ind, toks = self.lines[self.i]
        self.i += 1
        t0 = toks[0]
        if t0.kind == 'kw':
            if t0.val == 'global':
                return ('global', [t.val for t in toks[1:] if t.kind == 'ident'])
            if t0.val == 'if':
                return self.parse_if(ind, toks)
            if t0.val == 'case':
                return self.parse_case(ind, toks)
            if t0.val == 'repeat':
                return self.parse_repeat(ind, toks)
            if t0.val == 'exit':
                if len(toks) > 1 and toks[1].val == 'repeat':
                    return ('exitrepeat',)
                return ('exit',)
            if t0.val == 'next':
                return ('nextrepeat',)
            if t0.val == 'return':
                if len(toks) == 1:
                    return ('return', None)
                e, p = self.parse_expr(toks, 1)
                return ('return', e)
            if t0.val == 'set':
                # set the X to expr
                assert toks[1].val == 'the'
                name = toks[2].val
                assert toks[3].val == 'to'
                e, p = self.parse_expr(toks, 4)
                return ('settheprop', name, e)
            if t0.val == 'put':
                # put expr [into/after/before ...]  (only debug prints matter)
                e, p = self.parse_expr(toks, 1)
                if p < len(toks):
                    return ('put', ('str', '"<put-into>"'))
                return ('put', e)
            if t0.val == 'tell':
                target, p = self.parse_expr(toks, 1)
                block = self.parse_block(ind)
                self.expect_end('tell')
                return ('tell', target, block)
        # assignment or expression
        if not (t0.kind == 'op' and t0.val == '-'):
            lv, p = self.parse_postfix(toks, 0)
            if p < len(toks) and toks[p].kind == 'op' and toks[p].val == '=':
                rhs, p2 = self.parse_expr(toks, p + 1)
                assert p2 == len(toks), f'trailing tokens in assignment: {toks[p2:]}'
                return ('assign', lv, rhs)
        e, p = self.parse_expr(toks, 0)
        assert p == len(toks), f'trailing tokens: {toks[p:]} in {toks}'
        return ('expr', e)

    def expect_end(self, what):
        ind, toks = self.lines[self.i]
        assert toks[0].val == 'end', f'expected end {what}, got {toks}'
        self.i += 1

    def parse_if(self, ind, toks):
        # if cond then [stmt]
        # find 'then'
        depth = 0
        then_i = None
        for k in range(1, len(toks)):
            if toks[k].kind == 'kw' and toks[k].val == 'then':
                then_i = k
                break
        assert then_i, f'no then in {toks}'
        cond, p = self.parse_expr(toks[:then_i], 1)
        assert p == then_i
        if then_i + 1 < len(toks):
            # single-line if
            self.lines.insert(self.i, (ind + 2, toks[then_i + 1:]))
            block = [self.parse_statement()]
            return ('if', cond, block, None)
        block = self.parse_block(ind)
        else_block = None
        ind2, toks2 = self.lines[self.i]
        if toks2[0].val == 'else':
            self.i += 1
            if len(toks2) > 1:  # else if ... then  (on same line)
                assert toks2[1].val == 'if'
                nested = self.parse_if(ind, toks2[1:])
                else_block = [nested]
                return ('if', cond, block, else_block)
            else_block = self.parse_block(ind)
        self.expect_end('if')
        return ('if', cond, block, else_block)

    def parse_case(self, ind, toks):
        assert toks[-1].val == 'of'
        subject, p = self.parse_expr(toks[:-1], 1)
        clauses = []
        while True:
            ind2, toks2 = self.lines[self.i]
            if toks2[0].val == 'end':
                break
            assert toks2[-1].val == ':', f'bad case label {toks2}'
            self.i += 1
            if toks2[0].val == 'otherwise':
                labels = None
            else:
                labels = []
                # split on top-level commas
                parts = self.split_commas(toks2[:-1])
                for part in parts:
                    e, q = self.parse_expr(part, 0)
                    assert q == len(part)
                    labels.append(e)
            block = self.parse_block(ind2)
            clauses.append((labels, block))
        self.expect_end('case')
        return ('case', subject, clauses)

    @staticmethod
    def split_commas(toks):
        parts, cur, depth = [], [], 0
        for t in toks:
            if t.kind == 'op' and t.val in '([':
                depth += 1
            elif t.kind == 'op' and t.val in ')]':
                depth -= 1
            if t.kind == 'op' and t.val == ',' and depth == 0:
                parts.append(cur)
                cur = []
            else:
                cur.append(t)
        parts.append(cur)
        return parts

    def parse_repeat(self, ind, toks):
        if toks[1].val == 'with':
            var = toks[2].val
            if toks[3].val == '=':
                # repeat with i = a to b / down to b
                k = 4
                # find 'to' or 'down'
                depth = 0
                to_i = None
                for j in range(k, len(toks)):
                    if toks[j].kind == 'kw' and toks[j].val in ('to', 'down') and depth == 0:
                        to_i = j
                        break
                    if toks[j].kind == 'op' and toks[j].val in '([':
                        depth += 1
                    elif toks[j].kind == 'op' and toks[j].val in ')]':
                        depth -= 1
                a, p = self.parse_expr(toks[:to_i], k)
                down = toks[to_i].val == 'down'
                start = to_i + (2 if down else 1)
                b, p = self.parse_expr(toks, start)
                block = self.parse_block(ind)
                self.expect_end('repeat')
                return ('repeatwith', var, a, b, down, block)
            assert toks[3].val == 'in'
            lst, p = self.parse_expr(toks, 4)
            block = self.parse_block(ind)
            self.expect_end('repeat')
            return ('repeatin', var, lst, block)
        assert toks[1].val == 'while'
        cond, p = self.parse_expr(toks, 2)
        block = self.parse_block(ind)
        self.expect_end('repeat')
        return ('repeatwhile', cond, block)

    # ---- expressions (precedence climbing)
    def parse_expr(self, toks, p):
        return self.parse_or(toks, p)

    def parse_or(self, toks, p):
        a, p = self.parse_and(toks, p)
        while p < len(toks) and toks[p].kind == 'kw' and toks[p].val == 'or':
            b, p = self.parse_and(toks, p + 1)
            a = ('bin', 'or', a, b)
        return a, p

    def parse_and(self, toks, p):
        a, p = self.parse_cmp(toks, p)
        while p < len(toks) and toks[p].kind == 'kw' and toks[p].val == 'and':
            b, p = self.parse_cmp(toks, p + 1)
            a = ('bin', 'and', a, b)
        return a, p

    def parse_cmp(self, toks, p):
        a, p = self.parse_concat(toks, p)
        while p < len(toks) and ((toks[p].kind == 'op' and toks[p].val in ('=', '<>', '<', '>', '<=', '>=')) or
                                 (toks[p].kind == 'kw' and toks[p].val in ('contains', 'starts'))):
            op = toks[p].val
            b, p = self.parse_concat(toks, p + 1)
            a = ('bin', op, a, b)
        return a, p

    def parse_concat(self, toks, p):
        a, p = self.parse_add(toks, p)
        while p < len(toks) and toks[p].kind == 'op' and toks[p].val in ('&', '&&'):
            op = toks[p].val
            b, p = self.parse_add(toks, p + 1)
            a = ('bin', op, a, b)
        return a, p

    def parse_add(self, toks, p):
        a, p = self.parse_mul(toks, p)
        while p < len(toks) and toks[p].kind == 'op' and toks[p].val in ('+', '-'):
            op = toks[p].val
            b, p = self.parse_mul(toks, p + 1)
            a = ('bin', op, a, b)
        return a, p

    def parse_mul(self, toks, p):
        a, p = self.parse_unary(toks, p)
        while p < len(toks) and ((toks[p].kind == 'op' and toks[p].val in ('*', '/')) or
                                 (toks[p].kind == 'kw' and toks[p].val == 'mod')):
            op = toks[p].val
            b, p = self.parse_unary(toks, p + 1)
            a = ('bin', op, a, b)
        return a, p

    def parse_unary(self, toks, p):
        t = toks[p]
        if t.kind == 'op' and t.val == '-':
            a, p = self.parse_unary(toks, p + 1)
            return ('un', '-', a), p
        if t.kind == 'kw' and t.val == 'not':
            a, p = self.parse_unary(toks, p + 1)
            return ('un', 'not', a), p
        return self.parse_postfix(toks, p)

    def parse_postfix(self, toks, p):
        a, p = self.parse_primary(toks, p)
        while p < len(toks):
            t = toks[p]
            if t.kind == 'op' and t.val == '.':
                name = toks[p + 1].val
                p += 2
                if p < len(toks) and toks[p].kind == 'op' and toks[p].val == '(':
                    args, p = self.parse_args(toks, p)
                    a = ('mcall', a, name, args)
                else:
                    a = ('prop', a, name)
            elif t.kind == 'op' and t.val == '[':
                idx, p = self.parse_expr(toks, p + 1)
                assert toks[p].val == ']'
                a = ('index', a, idx)
                p += 1
            else:
                break
        return a, p

    def parse_args(self, toks, p):
        assert toks[p].val == '('
        p += 1
        args = []
        if toks[p].val == ')':
            return args, p + 1
        while True:
            e, p = self.parse_expr(toks, p)
            args.append(e)
            if toks[p].val == ',':
                p += 1
                continue
            assert toks[p].val == ')', f'expected ) got {toks[p]}'
            return args, p + 1

    def parse_primary(self, toks, p):
        t = toks[p]
        if t.kind == 'int':
            return ('num', int(t.val), False), p + 1
        if t.kind == 'float':
            return ('num', float(t.val), True), p + 1
        if t.kind == 'string':
            return ('str', t.val), p + 1
        if t.kind == 'symbol':
            return ('sym', t.val[1:]), p + 1
        if t.kind == 'kw':
            if t.val == 'VOID':
                return ('void',), p + 1
            if t.val == 'me':
                return ('me',), p + 1
            if t.val == 'the':
                # the X [of Y]  -- only simple forms used
                name = toks[p + 1].val
                p += 2
                if p < len(toks) and toks[p].kind == 'kw' and toks[p].val == 'of':
                    # the number of castMembers of castLib X  (debug only)
                    rest, p2 = self.parse_expr(toks, p + 1)
                    return ('the', name + '_of'), p2
                return ('the', name), p
            raise SyntaxError(f'unexpected keyword {t.val} in {toks}')
        if t.kind == 'op' and t.val == '(':
            e, p = self.parse_expr(toks, p + 1)
            assert toks[p].val == ')', f'expected ) in {toks}'
            return ('paren', e), p + 1
        if t.kind == 'op' and t.val == '[':
            p += 1
            if toks[p].val == ':':
                assert toks[p + 1].val == ']'
                return ('plist', []), p + 2
            if toks[p].val == ']':
                return ('list', []), p + 1
            items = []
            pairs = []
            is_plist = False
            while True:
                e, p = self.parse_expr(toks, p)
                if toks[p].val == ':':
                    is_plist = True
                    v, p = self.parse_expr(toks, p + 1)
                    pairs.append((e, v))
                else:
                    items.append(e)
                if toks[p].val == ',':
                    p += 1
                    continue
                assert toks[p].val == ']', f'expected ] in {toks}'
                p += 1
                break
            return (('plist', pairs) if is_plist else ('list', items)), p
        if t.kind == 'ident':
            if p + 1 < len(toks) and toks[p + 1].kind == 'op' and toks[p + 1].val == '(':
                args, p = self.parse_args(toks, p + 1)
                return ('call', t.val, args), p
            return ('id', t.val), p + 1
        raise SyntaxError(f'unexpected token {t} in {toks}')


# ---------------------------------------------------------------- script model

class Handler:
    def __init__(self, name, params, body):
        self.name, self.params, self.body = name, params, body


class Script:
    def __init__(self, kind, num, name):
        self.kind, self.num, self.name = kind, num, name
        self.props = []
        self.globals = []
        self.handlers = []
        self.ancestor = None  # class name

    def handler(self, name):
        for h in self.handlers:
            if h.name == name:
                return h
        return None


def parse_script(path):
    m = re.match(r'(\w+) (\d+) - (.+)\.ls$', path.name)
    kind, num, name = m.group(1), int(m.group(2)), m.group(3)
    name = re.sub(r'[^A-Za-z0-9_]', '_', name)
    sc = Script(kind, num, name)
    raw = path.read_text().split('\n')
    lines = []
    for ln in raw:
        if not ln.strip():
            continue
        indent = len(ln) - len(ln.lstrip(' '))
        lines.append((indent, tokenize(ln.strip())))
    i = 0
    while i < len(lines):
        ind, toks = lines[i]
        if toks[0].kind == 'kw' and toks[0].val == 'property':
            sc.props += [t.val for t in toks[1:] if t.kind == 'ident']
            i += 1
        elif toks[0].kind == 'kw' and toks[0].val == 'global':
            sc.globals += [t.val for t in toks[1:] if t.kind == 'ident']
            i += 1
        elif toks[0].kind == 'kw' and toks[0].val == 'on':
            hname = toks[1].val
            params = [t.val for t in toks[2:] if t.kind in ('ident', 'kw')]
            # body: lines until 'end' at indent 0
            j = i + 1
            body_lines = []
            while j < len(lines) and not (lines[j][0] == 0 and lines[j][1][0].val == 'end'):
                body_lines.append(lines[j])
                j += 1
            p = Parser(body_lines)
            body = []
            while p.i < len(p.lines):
                st = p.parse_statement()
                if st[0] == 'global':
                    sc.globals += st[1]
                else:
                    body.append(st)
            sc.handlers.append(Handler(hname, params, body))
            i = j + 1
        else:
            raise SyntaxError(f'{path.name}: unexpected top-level line {toks}')
    # detect ancestor
    new = sc.handler('new')
    if new:
        for st in new.body:
            if st[0] == 'assign' and st[1] == ('id', 'ancestor') and st[2][0] == 'call' and st[2][1] == 'new':
                target = st[2][2][0]
                if target[0] == 'prop' and target[1] == ('prop', ('id', 'g'), 'classes'):
                    sc.ancestor = target[2]
                elif target[0] == 'call' and target[1] == 'script':
                    sc.ancestor = target[2][0][1].strip('"')
                else:
                    raise SyntaxError(f'{sc.name}: unknown ancestor expr {target}')
    return sc


# ---------------------------------------------------------------- emitter

BUILTIN_FUNCS = {
    'point', 'rect', 'random', 'integer', 'float', 'string', 'symbol', 'abs', 'sqrt', 'power', 'cos', 'sin', 'atan',
    'bitOr', 'bitAnd', 'bitNot', 'bitXor', 'voidp', 'objectp', 'listp', 'integerp', 'floatp', 'stringp', 'symbolp',
    'ilk', 'value', 'chars', 'offset', 'length', 'charToNum', 'numToChar', 'sprite', 'member', 'castLib', 'sound',
    'label', 'marker', 'script', 'new', 'preloadMember', 'cursor', 'go', 'nothing', 'pass', 'puppetTempo',
    'clearGlobals', 'keyPressed', 'preloadNetThing', 'netDone', 'netAbort', 'getStreamStatus', 'downloadNetThing',
    'min', 'max', 'duplicate', 'image', 'timeout', 'max', 'min', 'updateStage', 'puppetSprite',
}

# handlers that exist on the runtime list/proplist/point/rect/sprite/member objects are called directly.


class Emitter:
    def __init__(self, scripts):
        self.scripts = {s.name: s for s in scripts}
        self.out = []
        self.warnings = []
        self.local_types = {}
        self.prop_types = {}
        self.cur = None

    # ---- scope helpers
    def all_handler_names(self, sc):
        names = set()
        s = sc
        while s:
            names |= {h.name for h in s.handlers}
            s = self.scripts.get(s.ancestor) if s.ancestor else None
        return names

    def emit_script(self, sc):
        if sc.kind == 'MovieScript':
            return self.emit_movie_script(sc)
        base = sc.ancestor or ('Behavior' if sc.kind == 'BehaviorScript' else 'LingoObject')
        self.cur = sc
        self.local_types = {}
        self.prop_types = self.infer_types(sc)
        self.out.append(f'export class {sc.name} extends {base} {{')
        self.out.append(f'  static lingoProps = {sc.props!r};'.replace("'", '"'))
        for h in sc.handlers:
            self.emit_handler(sc, h)
        self.out.append('}')
        self.out.append('')

    def emit_movie_script(self, sc):
        self.cur = sc
        self.prop_types = {}
        for h in sc.handlers:
            self.handler_names = {x.name for x in sc.handlers}
            self.params = [p for p in h.params if p != 'me']
            self.locals = set()
            self.collect_locals(h.body)
            self.local_types = self.infer_locals(h)
            self.out.append(f'export function {h.name}({", ".join(self.safe(p) for p in self.params)}) {{')
            if self.locals:
                self.out.append(f'  let {", ".join(self.safe(x) for x in sorted(self.locals))};')
            for st in h.body:
                self.emit_stmt(st, 1)
            self.out.append('}')
            self.out.append('')

    def emit_handler(self, sc, h):
        self.cur = sc
        self.handler_names = self.all_handler_names(sc)
        self.params = [p for p in h.params if p != 'me']
        self.locals = set()
        self.collect_locals(h.body)
        self.local_types = self.infer_locals(h)
        is_ctor = h.name == 'new'
        name = 'constructor' if is_ctor else h.name
        self.out.append(f'  {name}({", ".join(self.safe(p) for p in self.params)}) {{')
        body = list(h.body)
        if is_ctor:
            if sc.ancestor:
                first = body[0]
                assert first[0] == 'assign' and first[1] == ('id', 'ancestor'), f'{sc.name}: ancestor assignment must be first'
                args = first[2][2][1:]
                self.out.append(f'    super({", ".join(self.expr(a) for a in args)});')
                body = body[1:]
            else:
                self.out.append('    super();')
        self.in_ctor = is_ctor
        if self.locals:
            self.out.append(f'    let {", ".join(self.safe(x) for x in sorted(self.locals))};')
        for st in body:
            self.emit_stmt(st, 2)
        self.out.append('  }')

    def collect_locals(self, stmts):
        for st in stmts:
            k = st[0]
            if k == 'assign':
                lv = st[1]
                if lv[0] == 'id':
                    self.note_local(lv[1])
            elif k == 'if':
                self.collect_locals(st[2])
                if st[3]:
                    self.collect_locals(st[3])
            elif k == 'case':
                for labels, block in st[2]:
                    self.collect_locals(block)
            elif k == 'repeatwith':
                self.note_local(st[1])
                self.collect_locals(st[5])
            elif k == 'repeatin':
                self.note_local(st[1])
                self.collect_locals(st[3])
            elif k == 'repeatwhile':
                self.collect_locals(st[2])
            elif k == 'tell':
                self.collect_locals(st[2])

    def note_local(self, name):
        if name in self.cur.props or name in self.cur.globals or name in self.params or name == 'ancestor':
            return
        self.locals.add(name)

    RESERVED = {'class', 'function', 'var', 'let', 'const', 'delete', 'default', 'new', 'this', 'typeof', 'void',
                'switch', 'case', 'break', 'continue', 'for', 'while', 'do', 'in', 'of', 'if', 'else', 'return',
                'try', 'catch', 'finally', 'throw', 'import', 'export', 'extends', 'super', 'static', 'yield',
                'await', 'async', 'enum', 'instanceof', 'with', 'debugger', 'arguments', 'eval', 'null', 'true', 'false'}

    @classmethod
    def safe(cls, name):
        return name + '_' if name in cls.RESERVED else name

    def ident(self, name):
        if name in self.params or name in self.locals:
            return self.safe(name)
        if name == 'ancestor':
            return 'this'
        if name in self.cur.props:
            return f'this.{name}'
        if name in self.cur.globals:
            return f'G.{name}'
        if name in ('TRUE',):
            return '1'
        if name in ('FALSE',):
            return '0'
        if name == 'RETURN':
            return '"\\r"'
        if name == 'PI':
            return 'Math.PI'
        if name == 'EMPTY':
            return '""'
        if name == 'g':
            return 'G.g'
        self.warnings.append(f'{self.cur.name}: unknown identifier {name}')
        return name

    # ---- statements
    def emit_stmt(self, st, depth):
        ind = '  ' * depth
        k = st[0]
        if k == 'assign':
            self.out.append(ind + self.assign(st[1], st[2]) + ';')
        elif k == 'expr':
            self.out.append(ind + self.expr(st[1]) + ';')
        elif k == 'if':
            self.out.append(ind + f'if ({self.cond(st[1])}) {{')
            for s in st[2]:
                self.emit_stmt(s, depth + 1)
            if st[3]:
                if len(st[3]) == 1 and st[3][0][0] == 'if':
                    self.out.append(ind + '} else')
                    # emit nested if on same indentation
                    nested = st[3][0]
                    self.out[-1] = ind + f'}} else if ({self.cond(nested[1])}) {{'
                    for s in nested[2]:
                        self.emit_stmt(s, depth + 1)
                    self.emit_else_chain(nested[3], depth)
                    return
                self.out.append(ind + '} else {')
                for s in st[3]:
                    self.emit_stmt(s, depth + 1)
            self.out.append(ind + '}')
        elif k == 'case':
            self.out.append(ind + f'switch (_caseKey({self.expr(st[1])})) {{')
            for labels, block in st[2]:
                if labels is None:
                    self.out.append(ind + '  default: {')
                else:
                    for lb in labels:
                        self.out.append(ind + f'  case _caseKey({self.expr(lb)}):')
                    self.out[-1] += ' {'
                for s in block:
                    self.emit_stmt(s, depth + 2)
                self.out.append(ind + '    break; }')
            self.out.append(ind + '}')
        elif k == 'repeatwith':
            var, a, b, down, block = st[1:]
            va = self.expr(a)
            vb = self.expr(b)
            var = self.ident(var)
            if down:
                self.out.append(ind + f'for ({var} = {va}; {var} >= {vb}; {var}--) {{')
            else:
                self.out.append(ind + f'for ({var} = {va}; {var} <= {vb}; {var}++) {{')
            for s in block:
                self.emit_stmt(s, depth + 1)
            self.out.append(ind + '}')
        elif k == 'repeatin':
            var, lst, block = st[1:]
            self.out.append(ind + f'for ({self.ident(var)} of _iter({self.expr(lst)})) {{')
            for s in block:
                self.emit_stmt(s, depth + 1)
            self.out.append(ind + '}')
        elif k == 'repeatwhile':
            self.out.append(ind + f'while ({self.cond(st[1])}) {{')
            for s in st[2]:
                self.emit_stmt(s, depth + 1)
            self.out.append(ind + '}')
        elif k == 'exitrepeat':
            self.out.append(ind + 'break;')
        elif k == 'nextrepeat':
            self.out.append(ind + 'continue;')
        elif k == 'exit':
            self.out.append(ind + 'return;')
        elif k == 'return':
            if st[1] is None:
                self.out.append(ind + 'return;')
            elif st[1] == ('me',) and self.in_ctor:
                self.out.append(ind + 'return;')
            else:
                self.out.append(ind + f'return {self.expr(st[1])};')
        elif k == 'settheprop':
            self.out.append(ind + f'D.setThe("{st[1]}", {self.expr(st[2])});')
        elif k == 'put':
            self.out.append(ind + f'console.log({self.expr(st[1])});')
        elif k == 'tell':
            self.out.append(ind + f'D.tell({self.expr(st[1])}, () => {{')
            for s in st[2]:
                self.emit_stmt(s, depth + 1)
            self.out.append(ind + '});')
        else:
            raise NotImplementedError(k)

    def emit_else_chain(self, else_block, depth):
        ind = '  ' * depth
        if not else_block:
            self.out.append(ind + '}')
            return
        if len(else_block) == 1 and else_block[0][0] == 'if':
            nested = else_block[0]
            self.out.append(ind + f'}} else if ({self.cond(nested[1])}) {{')
            for s in nested[2]:
                self.emit_stmt(s, depth + 1)
            self.emit_else_chain(nested[3], depth)
            return
        self.out.append(ind + '} else {')
        for s in else_block:
            self.emit_stmt(s, depth + 1)
        self.out.append(ind + '}')

    def assign(self, lv, rhs):
        r = self.expr(rhs)
        if lv[0] == 'id':
            return f'{self.ident(lv[1])} = {r}'
        if lv[0] == 'prop':
            return f'{self.expr(lv[1])}.{lv[2]} = {r}'
        if lv[0] == 'index':
            return f'_setAt({self.expr(lv[1])}, {self.expr(lv[2])}, {r})'
        if lv[0] == 'the':
            return f'D.setThe("{lv[1]}", {r})'
        raise NotImplementedError(f'assign to {lv}')

    # ---- expressions
    def cond(self, e):
        return f'_truthy({self.expr(e)})'

    # Lingo divides ints as ints and floats as floats; JS has one number type, so we infer
    # what we can statically and fall back to a runtime check (_div) otherwise.
    FLOAT_HANDLERS = {'getLineIntersection'}      # every operand is a float at runtime (positions)
    FLOAT_PROPS = {'locH', 'locV'}                 # points in this game are always built from float()
    FLOAT_METHODS = {'getPosX', 'getPosY', 'getVelX', 'getVelY', 'getRatioLoaded', 'getHealthScalar', 'calcScale'}

    def infer_types(self, sc):
        """Per-script map of property name -> 'int' | 'float', from every assignment in the class chain."""
        types = {}
        chain = []
        c = sc
        while c:
            chain.append(c)
            c = self.scripts.get(c.ancestor) if c.ancestor else None
        for c in chain:
            for h in c.handlers:
                for lv, rhs in self.assignments(h.body):
                    name = None
                    if lv[0] == 'id' and lv[1] in c.props:
                        name = lv[1]
                    elif lv[0] == 'prop' and lv[1] == ('me',):
                        name = lv[2]
                    if not name:
                        continue
                    if self.is_float_expr(rhs, {}):
                        types[name] = 'float'
                    elif self.is_int_expr(rhs, {}) and types.get(name) != 'float':
                        types[name] = 'int'
                    elif name not in types:
                        types[name] = 'unknown'
        return types

    def assignments(self, stmts):
        for st in stmts:
            k = st[0]
            if k == 'assign':
                yield st[1], st[2]
            elif k == 'if':
                yield from self.assignments(st[2])
                if st[3]:
                    yield from self.assignments(st[3])
            elif k == 'case':
                for labels, block in st[2]:
                    yield from self.assignments(block)
            elif k == 'repeatwith':
                yield from self.assignments(st[5])
            elif k == 'repeatin':
                yield from self.assignments(st[3])
            elif k == 'repeatwhile':
                yield from self.assignments(st[2])

    def infer_locals(self, h):
        types = {}
        for lv, rhs in self.assignments(h.body):
            if lv[0] != 'id' or lv[1] in self.cur.props or lv[1] in self.cur.globals:
                continue
            if self.is_float_expr(rhs, types):
                types[lv[1]] = 'float'
            elif self.is_int_expr(rhs, types) and types.get(lv[1]) != 'float':
                types[lv[1]] = 'int'
            else:
                types.setdefault(lv[1], 'unknown')
        if h.name in self.FLOAT_HANDLERS:
            for prm in h.params:
                if prm != 'me':
                    types[prm] = 'float'
            for k in list(types):
                if types[k] == 'unknown':
                    types[k] = 'float'
        return types

    def var_type(self, e, local_types):
        if e[0] == 'id':
            n = e[1]
            if n in local_types:
                return local_types[n]
            if n in self.cur.props:
                return self.prop_types.get(n, 'unknown')
        if e[0] == 'prop' and e[1] == ('me',):
            return self.prop_types.get(e[2], 'unknown')
        return 'unknown'

    def is_float_expr(self, e, local_types=None):
        if local_types is None:
            local_types = self.local_types
        k = e[0]
        if k in ('id',) or (k == 'prop' and e[1] == ('me',)):
            if self.var_type(e, local_types) == 'float':
                return True
        if k == 'prop' and e[2] in self.FLOAT_PROPS:
            return True
        if k == 'mcall' and e[2] in self.FLOAT_METHODS:
            return True
        if k == 'num':
            return e[2]
        if k == 'call' and e[1] == 'float':
            return True
        if k == 'paren':
            return self.is_float_expr(e[1], local_types)
        if k == 'bin' and e[1] in ('+', '-', '*', '/'):
            return self.is_float_expr(e[2], local_types) or self.is_float_expr(e[3], local_types)
        if k == 'un' and e[1] == '-':
            return self.is_float_expr(e[2], local_types)
        return False

    def is_int_expr(self, e, local_types=None):
        if local_types is None:
            local_types = self.local_types
        k = e[0]
        if k in ('id',) or (k == 'prop' and e[1] == ('me',)):
            if self.var_type(e, local_types) == 'int':
                return True
        if k == 'num':
            return not e[2]
        if k == 'call' and e[1] in ('integer', 'random', 'charToNum', 'length', 'offset', 'bitOr', 'bitAnd'):
            return True
        if k == 'paren':
            return self.is_int_expr(e[1], local_types)
        if k == 'bin' and e[1] in ('+', '-', '*', 'mod'):
            return self.is_int_expr(e[2], local_types) and self.is_int_expr(e[3], local_types)
        if k == 'un' and e[1] == '-':
            return self.is_int_expr(e[2], local_types)
        if k == 'prop' and e[2] in ('count', 'spriteNum', 'number', 'width', 'height', 'left', 'right', 'top', 'bottom', 'keyCode', 'length'):
            return True
        return False

    def expr(self, e):
        k = e[0]
        if k == 'num':
            return repr(e[1]) if not e[2] else (repr(e[1]) if '.' in repr(e[1]) or 'e' in repr(e[1]) else repr(e[1]) + '.0')
        if k == 'str':
            return e[1].replace('\\', '\\\\')
        if k == 'sym':
            return f'"{e[1]}"'
        if k == 'void':
            return 'undefined'
        if k == 'me':
            return 'this'
        if k == 'id':
            return self.ident(e[1])
        if k == 'paren':
            return f'({self.expr(e[1])})'
        if k == 'list':
            return f'L({", ".join(self.expr(x) for x in e[1])})'
        if k == 'plist':
            items = ', '.join(f'[{self.expr(a)}, {self.expr(b)}]' for a, b in e[1])
            return f'PL([{items}])'
        if k == 'the':
            return f'D.the("{e[1]}")'
        if k == 'prop':
            obj, name = e[1], e[2]
            if obj == ('id', 'ancestor'):
                return f'this.{name}'
            return f'{self.expr(obj)}.{name}'
        if k == 'index':
            return f'_getAt({self.expr(e[1])}, {self.expr(e[2])})'
        if k == 'call':
            return self.call(e[1], e[2])
        if k == 'mcall':
            obj, name, args = e[1], e[2], e[3]
            a = ', '.join(self.expr(x) for x in args)
            if obj == ('id', 'ancestor'):
                return f'super.{name}({a})'
            return f'{self.expr(obj)}.{name}({a})'
        if k == 'un':
            if e[1] == '-':
                return f'_neg({self.expr(e[2])})'
            return f'!_truthy({self.expr(e[2])})'
        if k == 'bin':
            return self.binop(e)
        raise NotImplementedError(e)

    def binop(self, e):
        op, a, b = e[1], e[2], e[3]
        A, B = self.expr(a), self.expr(b)
        if op == 'and':
            return f'(_truthy({A}) && _truthy({B}))'
        if op == 'or':
            return f'(_truthy({A}) || _truthy({B}))'
        if op == '=':
            return f'_eq({A}, {B})'
        if op == '<>':
            return f'!_eq({A}, {B})'
        if op in ('<', '>', '<=', '>='):
            return f'({A} {op} {B})'
        if op == 'contains':
            return f'_contains({A}, {B})'
        if op == 'starts':
            return f'_starts({A}, {B})'
        if op == '&':
            return f'(_str({A}) + _str({B}))'
        if op == '&&':
            return f'(_str({A}) + " " + _str({B}))'
        if op == '+':
            if self.is_int_expr(a) and self.is_int_expr(b):
                return f'({A} + {B})'
            return f'_add({A}, {B})'
        if op == '-':
            if self.is_int_expr(a) and self.is_int_expr(b):
                return f'({A} - {B})'
            return f'_sub({A}, {B})'
        if op == '*':
            if self.is_int_expr(a) and self.is_int_expr(b):
                return f'({A} * {B})'
            return f'_mul({A}, {B})'
        if op == '/':
            if self.is_float_expr(a) or self.is_float_expr(b):
                return f'_fdiv({A}, {B})'
            if self.is_int_expr(a) and self.is_int_expr(b):
                return f'_idiv({A}, {B})'
            return f'_div({A}, {B})'
        if op == 'mod':
            return f'_mod({A}, {B})'
        raise NotImplementedError(op)

    def call(self, name, args):
        a = [self.expr(x) for x in args]
        if name == 'new':
            target = args[0]
            if target[0] == 'call' and target[1] == 'script':
                cls = f'script({a[0][len("script("):-1]})' if False else self.expr(target)
            else:
                cls = a[0]
            return f'_new({cls}{", " if a[1:] else ""}{", ".join(a[1:])})'
        if name in self.handler_names and name not in BUILTIN_FUNCS:
            return f'this.{name}({", ".join(a)})'
        if name in BUILTIN_FUNCS:
            return f'{name}({", ".join(a)})'
        self.warnings.append(f'{self.cur.name}: unknown function {name}')
        return f'{name}({", ".join(a)})'


def main():
    import json
    castlibs = json.load(open(ROOT / 'assets/members.json'))['castLibs']
    scripts = []
    for castdir in sorted(SRC.parent.glob('*/')):
        castname = castdir.name
        if castname == 'cartoon_network_enhancements':   # CN site plumbing (ad billboard etc.); stubbed in main.js
            continue
        for p in sorted(castdir.glob('*.ls')):
            if 'DEBUG' in p.name or 'Debug_' in p.name:
                continue
            try:
                sc = parse_script(p)
            except Exception as ex:
                print('PARSE FAIL', p.name, ex)
                raise
            sc.castLib = castlibs[castname]
            if castname != 'Lingo':
                sc.name = f'{castname}_{sc.name}'
            scripts.append(sc)
    # order: ancestors first
    by_name = {s.name: s for s in scripts}
    ordered, seen = [], set()

    def visit(s):
        if s.name in seen:
            return
        if s.ancestor and s.ancestor in by_name:
            visit(by_name[s.ancestor])
        seen.add(s.name)
        ordered.append(s)
    for s in scripts:
        visit(s)
    em = Emitter(scripts)
    em.out.append('// GENERATED by tools/lingo2js.py from the decompiled Lingo -- do not edit by hand.')
    em.out.append('import { G, L, PL, LingoObject, Behavior, _truthy, _eq, _add, _sub, _mul, _div, _fdiv, _idiv, _mod, _neg, _str, _contains, _starts, _getAt, _setAt, _new, _iter, _caseKey,')
    em.out.append('  point, rect, random, integer, float, string, symbol, abs, sqrt, power, cos, sin, atan, bitOr, bitAnd, bitNot, bitXor, voidp, objectp, listp, integerp, floatp, stringp, symbolp, ilk, value, chars, offset, length, charToNum, numToChar, min, max, duplicate } from "../runtime/lingo.js";')
    em.out.append('import { D, sprite, member, castLib, sound, label, marker, script, preloadMember, cursor, go, nothing, pass, puppetTempo, clearGlobals, keyPressed, preloadNetThing, netDone, netAbort, getStreamStatus, image } from "../runtime/director.js";')
    em.out.append('')
    for s in ordered:
        em.emit_script(s)
    # class registry for script("name") / _ClassDefinitions
    em.out.append('export const SCRIPTS = {')
    for s in ordered:
        if s.kind != 'MovieScript':
            em.out.append(f'  "{s.name}": {s.name},')
    em.out.append('};')
    em.out.append('export const SCRIPT_MEMBERS = {')
    for s in ordered:
        if s.kind != 'MovieScript':
            em.out.append(f'  "{s.castLib}:{s.num}": {s.name},')
    em.out.append('};')
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text('\n'.join(em.out) + '\n')
    print('wrote', OUT, len(em.out), 'lines;', len(ordered), 'scripts')
    for w in sorted(set(em.warnings)):
        print('WARN', w)


if __name__ == '__main__':
    main()
