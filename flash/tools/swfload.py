"""Load the SWF with pyswf (with a couple of robustness patches)."""
import warnings, sys
warnings.filterwarnings('ignore', category=SyntaxWarning)
from swf.stream import SWFStream
from swf.movie import SWF
from pathlib import Path

from common import need_swf

def _readString(self):
    s = b''
    while True:
        c = self.f.read(1)
        if not c or c == b'\x00':
            break
        s += c
    return s.decode('latin-1')
SWFStream.readString = _readString

import base64
if not hasattr(base64, 'encodestring'):   # removed in Python 3.9; pyswf still calls it
    base64.encodestring = lambda b: base64.encodebytes(b).decode()

def load():
    # pyswf misreads uncompressed (FWS) files; hand it a zlib-compressed copy instead
    import io, zlib
    raw = open(need_swf(), 'rb').read()
    if raw[:3] == b'FWS':
        raw = b'CWS' + raw[3:8] + zlib.compress(raw[8:])
    return SWF(io.BytesIO(raw))


def make_exporter():
    """pyswf's SVGExporter expects DefineFontInfo tags; Flash 6 files use DefineFont2, which
    carries its own code table. Feed it those instead."""
    from swf.export import SVGExporter
    from types import SimpleNamespace
    from swf.tag import TagDefineFont2

    class Exporter(SVGExporter):
        def export(self, swf, force_stroke=False):
            self._font2 = {t.characterId: t for t in swf.all_tags_of_type(TagDefineFont2)}
            return super().export(swf, force_stroke)

        def _serialize(self):
            from lxml import etree
            return etree.tostring(self.svg, encoding='UTF-8', xml_declaration=True)

        def export_define_shapes(self, tags):
            missing = {cid: SimpleNamespace(useGlyphText=True, codeTable=t.codeTable)
                       for cid, t in self._font2.items() if cid not in self.fontInfos}
            self.fontInfos.update(missing)
            return super().export_define_shapes(tags)
    return Exporter()
