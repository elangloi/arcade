"""Extract everything the port needs from the SWF.

uv run python extract.py

  ../assets/defs.svg        <defs> with every shape/text/image/font glyph as <g id="cN"> / font_N_code
  ../assets/movie.json      header, main timeline + every sprite's per-frame display list, labels,
                            sounds per frame, edit-text fields, buttons, fonts (advances)
  ../assets/sounds/N.mp3
"""
import json, struct, io
from pathlib import Path
from lxml import etree
import swfraw
from swfraw import Reader
from swfload import load, make_exporter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'assets'
OUT.mkdir(exist_ok=True)
(OUT / 'sounds').mkdir(exist_ok=True)
TW = 20.0  # twips per pixel


def mat(m):
    """SWF matrix (twips translation) -> [a, b, c, d, tx, ty] in pixels."""
    return [round(m['sx'], 5), round(m['r0'], 5), round(m['r1'], 5), round(m['sy'], 5), m['tx'] / TW, m['ty'] / TW]


def timeline(tags, swf_version):
    """Simulate PlaceObject2/RemoveObject2 into a per-frame display list snapshot."""
    frames, labels, sounds = [], {}, {}
    cur = {}   # depth -> object
    frame = 1
    pending_sounds = []
    touched = set()   # depths a PlaceObject hit in the current frame (keyframe changes)
    for code, name, body in tags:
        if name == 'ShowFrame':
            snap = {}
            for d, o in sorted(cur.items()):
                o2 = dict(o)
                if d in touched: o2['k'] = 1
                snap[str(d)] = o2
            frames.append(snap)
            touched = set()
            if pending_sounds:
                sounds[str(frame)] = pending_sounds; pending_sounds = []
            frame += 1
        elif name == 'FrameLabel':
            labels[body[:-1].decode('latin-1')] = frame
        elif name == 'PlaceObject2':
            po = swfraw.place_object2(body, swf_version)
            d = po['depth']
            obj = dict(cur.get(d, {})) if po['flags'] & 1 else {}
            if 'id' in po: obj['id'] = po['id']
            if 'matrix' in po: obj['m'] = mat(po['matrix'])
            if 'cxform' in po: obj['cx'] = po['cxform']
            if 'name' in po: obj['name'] = po['name']
            if 'ratio' in po: obj['ratio'] = po['ratio']
            if 'clipDepth' in po: obj['clip'] = po['clipDepth']
            if 'clipActions' in po:
                obj['events'] = sorted({n for ev, k, c in po['clipActions'] for b, n in swfraw.CLIP_EVENTS.items() if ev & b})
            if 'm' not in obj: obj['m'] = [1, 0, 0, 1, 0, 0]
            cur[d] = obj; touched.add(d)
        elif name == 'PlaceObject':
            r = Reader(body); cid = r.u16(); d = r.u16(); m = r.matrix()
            cur[d] = {'id': cid, 'm': mat(m)}; touched.add(d)
        elif name == 'RemoveObject2':
            cur.pop(struct.unpack('<H', body[:2])[0], None)
        elif name == 'RemoveObject':
            cur.pop(struct.unpack('<H', body[2:4])[0], None)
        elif name == 'StartSound':
            r = Reader(body); sid = r.u16(); flags = r.u8()
            info = {'id': sid}
            if flags & 0x20: info['stop'] = True
            if flags & 0x10: info['noMultiple'] = True
            if flags & 0x01: r.u32()
            if flags & 0x02: r.u32()
            if flags & 0x04: info['loops'] = r.u16()
            pending_sounds.append(info)
    return {'frames': frames, 'labels': labels, 'sounds': sounds}


def edit_text(body):
    # flags are stored as two bit-packed bytes; read little-endian the first byte is the low one
    r = Reader(body); cid = r.u16(); b = r.rect(); flags = r.u16()
    has_text, word_wrap, multiline, read_only = flags & 0x80, flags & 0x40, flags & 0x20, flags & 0x08
    has_color, has_maxlen, has_font = flags & 0x04, flags & 0x02, flags & 0x01
    auto_size, has_layout, border, html = flags & 0x4000, flags & 0x2000, flags & 0x800, flags & 0x200
    t = {'bounds': [b[0] / TW, b[2] / TW, b[1] / TW, b[3] / TW], 'wordWrap': bool(word_wrap), 'multiline': bool(multiline),
         'readOnly': bool(read_only), 'autoSize': bool(auto_size), 'html': bool(html), 'border': bool(border)}
    if has_font:
        t['font'] = r.u16(); t['size'] = r.u16() / TW
    if has_color:
        t['color'] = '#%02x%02x%02x' % (r.u8(), r.u8(), r.u8()); r.u8()
    if has_maxlen: t['maxLength'] = r.u16()
    if has_layout:
        t['align'] = ['left', 'right', 'center', 'justify'][r.u8()]; t['leftMargin'] = r.u16() / TW; t['rightMargin'] = r.u16() / TW
        t['indent'] = r.u16() / TW; t['leading'] = r.s16() / TW
    t['var'] = r.string()
    if has_text: t['text'] = r.string()
    return cid, t


def main():
    body, pos, hdr = swfraw.load_body()
    tags = list(swfraw.read_tags(body, pos))
    ver = hdr['version']
    movie = {'width': hdr['frame_size'][1] / TW, 'height': hdr['frame_size'][3] / TW, 'rate': hdr['rate'],
             'main': timeline(tags, ver), 'sprites': {}, 'texts': {}, 'buttons': {}, 'fonts': {}, 'sounds': {}, 'bg': '#ffffff'}
    for code, name, tb in tags:
        if name == 'DefineSprite':
            sid, fc, stags = swfraw.sprite_tags(tb)
            movie['sprites'][str(sid)] = timeline(stags, ver)
        elif name == 'DefineEditText':
            cid, t = edit_text(tb); movie['texts'][str(cid)] = t
        elif name == 'DefineButton2':
            bid, recs, acts = swfraw.button2(tb)
            movie['buttons'][str(bid)] = {'records': [
                {'up': bool(r['flags'] & 1), 'over': bool(r['flags'] & 2), 'down': bool(r['flags'] & 4), 'hit': bool(r['flags'] & 8),
                 'id': r['id'], 'depth': r['depth'], 'm': mat(r['matrix'])} for r in recs],
                'press': any(c & 0x4 for c, _ in acts), 'release': any(c & 0x8 for c, _ in acts)}
        elif name == 'SetBackgroundColor':
            movie['bg'] = '#%02x%02x%02x' % (tb[0], tb[1], tb[2])

    # pyswf for the vector art, fonts and sounds
    s = load()
    svg = etree.fromstring(make_exporter().export(s))
    ns = {'svg': 'http://www.w3.org/2000/svg'}
    defs = svg.find('svg:defs', ns)
    sprite_ids = {f'c{k}' for k in movie['sprites']}
    keep = etree.Element('{http://www.w3.org/2000/svg}svg', nsmap={None: 'http://www.w3.org/2000/svg', 'xlink': 'http://www.w3.org/1999/xlink'})
    d2 = etree.SubElement(keep, '{http://www.w3.org/2000/svg}defs')
    # pyswf ignores a DefineText's own matrix (it offsets/scales the glyph run inside the character)
    text_matrices = {}
    for code, name, tb in tags:
        if name in ('DefineText', 'DefineText2'):
            r = Reader(tb); cid = r.u16(); r.rect(); text_matrices[f'c{cid}'] = mat(r.matrix())
    for el in defs:
        if el.get('id') in sprite_ids:
            continue     # sprites are composed at runtime from movie.json
        tm = text_matrices.get(el.get('id'))
        if tm and tm != [1, 0, 0, 1, 0, 0]:
            el.set('transform', 'matrix(%s)' % ' '.join(repr(round(v, 4)) for v in tm))
        d2.append(el)
    # pyswf writes glyph outlines in pixels (twips / 20) but scales them as 1024-unit em squares
    for path in keep.iter('{http://www.w3.org/2000/svg}path'):
        if (path.get('id') or '').startswith('font_') and path.get('transform') == 'scale(0.0009765625)':
            path.set('transform', 'scale(%s)' % (20 / 1024))
    (OUT / 'defs.svg').write_bytes(etree.tostring(keep, encoding='UTF-8', xml_declaration=True))

    from swf.tag import TagDefineFont2, TagDefineSound
    from swf.sound import write_sound_to_file
    for t in s.all_tags_of_type(TagDefineFont2):
        movie['fonts'][str(t.characterId)] = {
            'name': t.fontName.decode('latin-1') if isinstance(t.fontName, bytes) else str(t.fontName), 'ascent': getattr(t, 'ascent', 0) / 1024, 'descent': getattr(t, 'descent', 0) / 1024,
            'advances': {str(c): a / 1024 for c, a in zip(t.codeTable, t.fontAdvanceTable)} if getattr(t, 'fontAdvanceTable', None) else {},
            'glyphs': [str(c) for c in t.codeTable]}
    for t in s.all_tags_of_type(TagDefineSound):
        f = OUT / 'sounds' / f'{t.soundId}.mp3'
        with open(f, 'wb') as fh:
            write_sound_to_file(t, fh)
        movie['sounds'][str(t.soundId)] = f'sounds/{t.soundId}.mp3'

    (OUT / 'movie.json').write_text(json.dumps(movie, separators=(',', ':')))
    print('sprites', len(movie['sprites']), 'texts', len(movie['texts']), 'buttons', len(movie['buttons']),
          'fonts', {k: (v['name'], len(v['glyphs'])) for k, v in movie['fonts'].items()}, 'sounds', len(movie['sounds']))
    print('main frames', len(movie['main']['frames']), 'labels', movie['main']['labels'])


if __name__ == '__main__':
    main()
