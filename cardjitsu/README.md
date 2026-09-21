# Card-Jitsu — JS recreation

A playable recreation of Club Penguin's *Card-Jitsu* (Disney / New Horizon Interactive, 2008 — the
Flash 9 / ActionScript 2 dojo card game), played against the Sensei. `card.swf` is the game engine
(table, cards, clock, help), the ninjas and every fight are separate SWFs it loaded at runtime, and
each card's picture is its own little SWF. This port plays all of that on the shared Flash-style
player in [`../flash`](../flash), with the client's ActionScript ported by hand from a
decompilation and the server side — which Club Penguin ran for real — re-implemented in JS. No
emulator, no Java.

**Rules.** Fire beats snow, snow beats water, water beats fire; the same element, the higher number
wins; a tie discards both. Win with three cards of one element in three different colours, or one
card of each element in three different colours. Twenty seconds to pick or the first card plays
itself.

**The Sensei.** He sees your card and counters it more often the lower your belt (the real Sensei
was unbeatable until black belt). Belts move after every game, win or lose, and are kept in the
browser; the ladder is the original's (white → black), compressed so it doesn't take a hundred
games.

Not in this version: power cards (their effects lived on the server; the deck is the 405 basic
cards), the award ceremony movie, and the two-player mode — the multiplayer service is the
natural home for that.

## Play

From the repo root: `python3 serve.py 8765`, then <http://localhost:8765/cardjitsu/web/>, or
through the arcade shell at `/single/cardjitsu`. `?mute=1` silences it, `?debug=1` logs each round.

## Layout

| Path | What |
|------|------|
| `original/` | `card.swf` (the 2009 engine, from the Club Penguin Archives), `battles/` (the ninja animations), `icons/` (one SWF per card), `lang/en/locale.swf`, `award/award.swf`, `bootstrap.swf`, `tutorial.swf`, `instructions_en.swf`, and `cards.json` — Club Penguin's card database (`play/web_service/game_configs/cards.json`). The battles, icons, locale and award came from the [CPSC](https://github.com/sticks-stuff/CPSC) media dump of `play/v2/games/card/`. |
| `decompiled/code/` | The AVM1 bytecode of `card.swf` decompiled to readable pseudo-AS2: `GameEngine`, `CardPlayer`, `Card`, `BattleController`, `PowerController`, `Clock`, `Layout`, `ClientProxy` … |
| `assets/` | `defs.svg`, `movie.json`, `sounds/` for the engine; `battles/<name>/`, `icons/<id>/`, `lang/en/` the same for each loaded SWF. |
| `web/` | `game.js` (the port + the local "server": deal, judge, win detection, the Sensei), `cards.js` (generated), `index.html`. |
| `tools/gen_cards.py` | Regenerates `web/cards.js` from `original/cards.json`. `tools/shrink_icons.py` trims the icon SVGs to one decimal. |

## Rebuilding from the originals

```bash
cd ../flash/tools
uv run python extract.py --game ../../cardjitsu --swf ../../cardjitsu/original/card.swf
uv run python dump_code.py --game ../../cardjitsu --swf ../../cardjitsu/original/card.swf
for f in ambient tie walk f_attack f_react w_attack w_react s_attack s_react; do
  uv run python extract.py --game ../../cardjitsu --swf ../../cardjitsu/original/battles/$f.swf --out ../../cardjitsu/assets/battles/$f
done
for f in ../../cardjitsu/original/icons/*.swf; do
  uv run python extract.py --game ../../cardjitsu --swf $f --out ../../cardjitsu/assets/icons/$(basename $f .swf)
done
uv run python extract.py --game ../../cardjitsu --swf ../../cardjitsu/original/lang/en/locale.swf --out ../../cardjitsu/assets/lang/en
cd ../../cardjitsu && python3 tools/shrink_icons.py && python3 tools/gen_cards.py
```

## Container

`Dockerfile` builds an nginx image serving `web/`, `assets/` and the shared player; the compose
stack mounts it at `/club-penguin-card-jitsu/`. Build from the repo root:
`docker build -f cardjitsu/Dockerfile -t arcade/cardjitsu .`
