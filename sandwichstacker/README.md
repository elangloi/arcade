# 625 Sandwich Stacker — JS recreation

A personal, playable recreation of Disney's *Lilo & Stitch: 625 Sandwich Stacker* (a 2003 Flash 6
game). The original is a single SWF; this port plays its timelines, vector art and sounds on a small
Flash-style player written for the browser (SVG), with the game's ActionScript 2 logic ported by
hand from a decompilation of the original bytecode. No emulator, no Java.

Catch the good ingredients on Reuben's plate, dodge the rotten ones (three hits = game over), and
finish the sandwich with the bread the toaster pops. Taller sandwiches score more.

## Play

From the repo root:

```bash
python3 serve.py 8765
```

Then open <http://localhost:8765/sandwichstacker/web/>. Any static file server works — the page only
needs `web/` and `assets/`.

Controls: **←/→** move the plate; **space / enter** continue after a level. QUIT / HELP / PAUSE are
on-screen buttons.

Query flags: `?mute=1` silences the game, `?debug=1` logs catches and misses to the console,
`?bg=1` keeps the clock running while the tab is hidden (the game normally pauses).

## Layout

| Path | What |
|------|------|
| `original/` | `625-sandwich-stacker.swf` (the game) and a title-screen reference shot. |
| `decompiled/code/` | The AVM1 bytecode of every frame, button and clip event, decompiled to readable pseudo-AS2 (`main.txt`, `spriteN.txt`). This is what `web/game.js` was ported from. |
| `assets/` | `defs.svg` (every shape, text and font glyph as an SVG symbol), `movie.json` (main timeline + every sprite's per-frame display list, labels, edit-text fields, buttons, font metrics), `sounds/*.mp3`. |
| `web/` | The game. `player.js` (timelines, display list, MovieClip/TextField/Button, colour transforms, sound, input), `game.js` (the ported game logic, keyed by the SWF's sprite ids and frame labels), `index.html`. |
| `tools/` | The extraction pipeline. Python via `uv` (`.python-version` pins 3.12). |

## Rebuilding from the original

```bash
cd tools
uv run python extract.py     # art, timelines, texts, buttons, fonts, sounds -> ../assets
uv run python dump_code.py   # AVM1 bytecode -> ../decompiled/code/*.txt
```

- `swfraw.py` — raw SWF tag reader (PlaceObject2, DefineButton2, DefineEditText, clip events, ...).
- `swfload.py` — loads the SWF with [pyswf](https://github.com/timknip/pyswf) (patched for Python 3
  and this file) and exports the vector art to SVG.
- `avm1.py` — a small AVM1 (Flash 6 ActionScript) decompiler used by `dump_code.py`.
- `extract.py` — writes `assets/`. Fixes pyswf's glyph scale and applies each static text's own
  matrix (pyswf drops it), which is what keeps the title and the multi-line screens aligned.

## Container

`Dockerfile` builds an nginx image serving `web/` and `assets/`; the compose stack in `../compose`
mounts it at `/lilo-and-stitch-sandwich-stacker/`.

```bash
docker build -t arcade/sandwichstacker .
docker run --rm -p 8080:80 arcade/sandwichstacker   # http://localhost:8080/
```
