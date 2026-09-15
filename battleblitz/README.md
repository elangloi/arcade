# Teen Titans: Battle Blitz — JS recreation

A personal, playable recreation of Cartoon Network's 2003 Shockwave game *Teen Titans: Battle Blitz*
(developed by PopNYC / This Is Pop). The original was a Macromedia Director 8 movie; this port runs
the game's own Lingo logic (mechanically transpiled to JavaScript) on a small Director-style player
written for the browser, using the original art and sounds extracted from the game files.

Play as any of the five Titans (Robin, Raven, Cyborg, Starfire, Beast Boy) against the villains
(Jinx, Gizmo, Mammoth, Cinderblock, Plasmus) — or switch sides and play as a villain.

## Play

```bash
python3 tools/serve.py 8765
```

Then open <http://localhost:8765/web/>. Any static file server rooted at this folder works.

Controls: arrows move/jump (down = block), **Z** punch, **X** kick, **P** pause / controls, **Esc** back to
the select screen. Special moves are listed on each fighter's Controls screen.

## Layout

| Path | What |
|------|------|
| `original/` | The recovered game files: `battleblitz.dcr` (main movie), `char_*.cct` (per-character casts), the Flash title shell. |
| `decompiled/` | ProjectorRays output — 374 Lingo scripts (`battleblitz/casts/Lingo/*.ls`) and raw chunk dumps. |
| `assets/` | Extracted PNGs, WAVs, `members.json` (every cast member + film loops), `score.json` (the Director score: frames, labels, sprite spans, behaviours). |
| `web/` | The game. `runtime/lingo.js` (Lingo value semantics), `runtime/director.js` (stage, sprites, inks, score player, film loops, sound, input), `game/classes.js` (generated from the Lingo — don't edit), `main.js`, `index.html`. |
| `tools/` | The pipeline (see below). Python via `uv` (`.python-version` pins 3.12). |

## Rebuilding from the originals

```bash
cd tools
uv run python extract.py      # bitmaps (all bit depths, palettes, JPEG members) + raw sounds -> ../assets
uv run python sounds.py       # Mac 'snd ' resources -> WAV
uv run python score.py        # score + labels -> ../assets/score.json
uv run python members.py      # unified member table + film loops -> ../assets/members.json
uv run python lingo2js.py     # Lingo -> ../web/game/classes.js
```

`decompiled/` was produced with `tools/ProjectorRays/projectorrays decompile <file> --dump-scripts --dump-chunks --dump-json`
(built from source; needs the Boost headers and static libmpg123 under `tools/deps/`).

## Notes on fidelity

* Game logic, AI, damage tables, physics, timings and hitboxes are the original code, run at the
  original 30 fps. The score (timeline) drives menus and round transitions exactly as in Director.
* Sprites use Director's ink rules: white is transparent under *background transparent*, *matte*
  keys out only white connected to the edge.
* The original loaded character casts over the network; here the loading bars reflect image loading.
* `window.soak([[titan, villain], ...], seconds)` in the browser console runs AI-vs-AI matches for testing.
