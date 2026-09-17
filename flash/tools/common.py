"""Where a game's files live. Every tool takes `--game <dir>` (default: the current directory) and
finds the SWF in <game>/original/ (or `--swf path`); output goes to <game>/assets (or `--out dir`)
and <game>/decompiled."""
import sys
from pathlib import Path


def _arg(name):
    if name in sys.argv:
        i = sys.argv.index(name); v = sys.argv[i + 1]; del sys.argv[i:i + 2]; return v
    return None


GAME = Path(_arg('--game') or '.').resolve()
_swf = _arg('--swf')
if _swf:
    SWF_PATH = Path(_swf).resolve()
else:
    cands = sorted((GAME / 'original').glob('*.swf')) if (GAME / 'original').exists() else []
    SWF_PATH = cands[0] if len(cands) == 1 else None   # several swfs -> say which with --swf
_out = _arg('--out')
ASSETS = Path(_out).resolve() if _out else GAME / 'assets'   # --out: e.g. a sub-movie's own assets folder
DECOMPILED = GAME / 'decompiled'


def need_swf():
    if SWF_PATH is None or not SWF_PATH.exists():
        sys.exit(f'no SWF found under {GAME}/original — pass --game <dir> and/or --swf <file>')
    return SWF_PATH
