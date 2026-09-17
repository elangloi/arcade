# Pizzatron 3000 — JS recreation

A personal, playable recreation of Club Penguin's *Pizzatron 3000* (Disney / New Horizon
Interactive, the 2007 Flash 8 / ActionScript 2 version with Candy Mode). The original is
`pizzatron.swf` plus a handful of companion SWFs it loads at runtime (the title logo, the sauce
bottles and the English strings). This port plays those timelines, vector art and sounds on the
shared Flash-style player in [`../flash`](../flash), with the game's ActionScript ported by hand
from a decompilation of the original bytecode. No emulator, no Java.

Make the pizza on the conveyor belt match the order on the screen: spread the right sauce over the
whole pizza, drop the cheese, add the toppings, and let it roll off the end. Five mistakes and
Pizzatron shuts down; forty pizzas finish the shift. Flip the switch on the title screen for
Candy Mode.

The Club Penguin shell is stubbed: no coins are banked, no stamps are sent, and "Quit"/"Done"
return to the title screen.

## Play

From the repo root:

```bash
python3 serve.py 8765
```

Then open <http://localhost:8765/pizzatron/web/>.

Controls: mouse only. Click an ingredient to pick it up. **Hold** the mouse button to squirt
sauce and wave it over the pizza until the whole thing is covered; **release** over the pizza to
drop cheese or a topping. Letting go anywhere else throws the ingredient away.

Query flags: `?mute=1` silences the game, `?debug=1` logs each finished pizza to the console,
`?bg=1` keeps the clock running while the tab is hidden.

## Layout

| Path | What |
|------|------|
| `original/` | `pizzatron.swf` and `lang/en/` (`locale.swf`, `title.swf`, the four sauce-bottle SWFs) as served by `media1.clubpenguin.com/play/v2/games/pizzatron/`. |
| `decompiled/code/` | The AVM1 bytecode decompiled to readable pseudo-AS2 (`main.txt`, `spriteN.txt`). The game itself is main frame 3; the `com.clubpenguin.*` classes are the shell glue. |
| `assets/` | `defs.svg`, `movie.json`, `sounds/` for the main movie; `lang/en/<name>/` the same for each companion SWF. |
| `web/` | `game.js` (the ported logic), `tables.js` (generated: the 48 orders and the stop-frames), `index.html`. |
| `tools/gen_tables.py` | Regenerates `web/tables.js` from the decompilation. |

## Rebuilding from the originals

```bash
cd ../flash/tools
uv run python extract.py --game ../../pizzatron
for f in locale title sauce sauce_squeeze hotsauce hotsauce_squeeze; do
  uv run python extract.py --game ../../pizzatron --swf ../../pizzatron/original/lang/en/$f.swf --out ../../pizzatron/assets/lang/en/$f
done
uv run python dump_code.py --game ../../pizzatron
cd ../../pizzatron/tools && uv run --project ../../flash/tools python gen_tables.py
```

## Container

`Dockerfile` builds an nginx image serving `web/`, `assets/` and the shared player; the compose
stack in `../compose` mounts it at `/club-penguin-pizzatron/`. Build from the repo root:

```bash
docker build -f pizzatron/Dockerfile -t arcade/pizzatron .
```
