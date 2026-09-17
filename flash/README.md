# flash — shared toolkit for the Flash (SWF) ports

Everything the AS2-era Flash games in this arcade have in common.

| Path | What |
|------|------|
| `web/player.js` | A small Flash-style player rendering to SVG: timelines and display lists, MovieClip/TextField/Button, masks, colour transforms, `attachMovie`/`duplicateMovieClip`/`loadClip`, shape-accurate `hitTest`, sounds, mouse and keyboard. The games' `game.js` import it as `../../flash/web/player.js`. |
| `tools/` | The extraction pipeline (Python via `uv`, 3.12): `swfraw.py` (raw tag reader), `swfload.py` (pyswf, patched for Python 3 and for FWS files), `avm1.py` (an AVM1 bytecode decompiler that also recovers `&&`/`||`), `extract.py` (art, timelines, texts, buttons, fonts, sounds, linkage names, locale strings → `<game>/assets`), `dump_code.py` (→ `<game>/decompiled/code`), `compose.py` (render one sprite frame to a standalone SVG). |

Every tool takes `--game <dir>` (the game folder, with the SWF in `<game>/original/`), plus
`--swf <file>` and `--out <dir>` when a game has more than one SWF:

```bash
cd flash/tools
uv run python extract.py --game ../../sandwichstacker
uv run python dump_code.py --game ../../pizzatron
uv run python compose.py --game ../../pizzatron 272 5 hand.svg
```

## Porting a game

1. Drop the SWF(s) in `<game>/original/`, run `extract.py` and `dump_code.py`.
2. Read `<game>/decompiled/code/main.txt` and the `spriteN.txt` files, then write `<game>/web/game.js`:
   hooks on frames (`P.onFrame(spriteId, frame, fn)`), clip placement (`P.onLoad(spriteId, fn)`)
   and buttons (`P.onButton(id, fn)`), with the game's variables in plain JS. Sprite ids, instance
   names and frame labels stay the original ones so the decompilation reads across.
3. `index.html` boots it; a `Dockerfile` built from the repo root copies `flash/web/` next to the game.

Player behaviours that matter (learned the hard way): frame scripts run only on frame entry;
once a script sets `_x`/`_xscale`/… the timeline stops driving that clip; script-created clips
live above timeline depths; buttons fire on press or release per the SWF; non-selectable text
never takes the mouse; the frame clock keeps ticking when the tab is hidden only with `?bg=1`.
