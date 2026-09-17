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
| `web/` | The game: `game.js` (the ported game logic, keyed by the SWF's sprite ids and frame labels) on the shared player in [`../flash/web/player.js`](../flash/web/player.js), and `index.html`. |

## Rebuilding from the original

The toolkit lives in [`../flash/tools`](../flash/tools):

```bash
cd ../flash/tools
uv run python extract.py --game ../../sandwichstacker     # art, timelines, texts, buttons, fonts, sounds -> assets/
uv run python dump_code.py --game ../../sandwichstacker   # AVM1 bytecode -> decompiled/code/*.txt
```

## Container

`Dockerfile` builds an nginx image serving `web/`, `assets/` and the shared player; the compose
stack in `../compose` mounts it at `/lilo-and-stitch-sandwich-stacker/`. Build from the repo root:

```bash
docker build -f sandwichstacker/Dockerfile -t arcade/sandwichstacker .
docker run --rm -p 8080:80 arcade/sandwichstacker   # http://localhost:8080/
```
