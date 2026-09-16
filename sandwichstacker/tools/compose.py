"""Render one frame of a sprite (or the main timeline) to a standalone SVG.

uv run python compose.py <spriteId|main> <frame> out.svg [--pad 4]

Nested sprites are drawn at their first frame (the pose a stopped clip shows). Only the
shapes/texts actually used are copied out of defs.svg, so the output is small.
"""
import json, sys, re
from pathlib import Path
from lxml import etree

ROOT = Path(__file__).resolve().parent.parent
NS = 'http://www.w3.org/2000/svg'
XLINK = 'http://www.w3.org/1999/xlink'
movie = json.load(open(ROOT / 'assets' / 'movie.json'))
defs_doc = etree.parse(str(ROOT / 'assets' / 'defs.svg'))
defs_by_id = {el.get('id'): el for el in defs_doc.getroot().iter() if el.get('id')}


def matrix(m):
    return 'matrix(%s)' % ' '.join(('%.4f' % v).rstrip('0').rstrip('.') for v in m)


def compose(parent, sid, frame, used):
    tl = movie['main'] if sid == 'main' else movie['sprites'][str(sid)]
    lst = tl['frames'][frame - 1]
    for d, rec in sorted(lst.items(), key=lambda kv: int(kv[0])):
        cid = str(rec['id'])
        g = etree.SubElement(parent, '{%s}g' % NS, transform=matrix(rec['m']))
        cx = rec.get('cx')
        if cx and cx['mul'][3] < 1:
            g.set('opacity', str(cx['mul'][3]))
        if cid in movie['sprites']:
            compose(g, cid, 1, used)
        elif cid in movie['texts']:
            continue   # dynamic text: nothing to draw statically
        else:
            use = etree.SubElement(g, '{%s}use' % NS)
            use.set('{%s}href' % XLINK, '#c' + cid)
            used.add('c' + cid)


def collect(ids, out):
    """Copy the defs needed (shapes plus anything they reference, e.g. font glyphs, images)."""
    todo = list(ids)
    while todo:
        i = todo.pop()
        if i in out or i not in defs_by_id:
            continue
        el = defs_by_id[i]
        out[i] = el
        for ref in el.iter():
            h = ref.get('{%s}href' % XLINK) or ref.get('href')
            if h and h.startswith('#'):
                todo.append(h[1:])
            for attr in ('fill', 'stroke', 'filter', 'clip-path', 'mask'):
                v = ref.get(attr)
                if v and v.startswith('url(#'):
                    todo.append(v[5:-1])


def main():
    sid, frame, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    pad = float(sys.argv[sys.argv.index('--pad') + 1]) if '--pad' in sys.argv else 4
    svg = etree.Element('{%s}svg' % NS, nsmap={None: NS, 'xlink': XLINK})
    defs = etree.SubElement(svg, '{%s}defs' % NS)
    root = etree.SubElement(svg, '{%s}g' % NS, id='art')
    used = set()
    compose(root, sid, frame, used)
    found = {}
    collect(used, found)
    for i in sorted(found):
        defs.append(etree.fromstring(etree.tostring(found[i])))
    svg.set('viewBox', 'BBOX')     # filled in by a browser pass (see fit_bbox.py) or by hand
    Path(out).write_bytes(etree.tostring(svg, xml_declaration=True, encoding='UTF-8'))
    print(out, 'uses', len(used), 'defs', len(found))


if __name__ == '__main__':
    main()
