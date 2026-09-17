# Noby Noby Boy — a homage

An original, browser-native tribute to Keita Takahashi's *Noby Noby Boy* (Namco Bandai, PS3, 2009).
The real game is a PS3 exclusive with no Flash/Shockwave source to port, so unlike the other
cabinets this one is written from scratch: WebGL via [Three.js](https://threejs.org) (vendored,
MIT), a stretchy verlet-rope BOY, a randomly populated floating island, and GIRL growing across
the solar system from what you report.

What it keeps from the original, as far as research allowed:

- **BOY** — pink head and butt, green middle, four stubby purple legs on each end. The left stick
  (WASD) moves his front, the right stick (arrows) his rear; pull them apart and he stretches.
  The D-pad (C/V) scrolls colour bands along his body.
- **Eat everything** — hold L2 (E) and whatever is in front of his face goes in: people, chickens,
  cows, land sharks, toucans (with riders), hover cars, walking mechs, robots, donuts, spinning
  tops, trees. It travels down him as a lump and R2 (Q) pops it out the back, unharmed. Eating
  makes him stretchier. L1 (Space) jumps, R1 (Shift) floats.
- **The island** — a flat floating rectangle you can fall off (the house takes you back), regenerated
  each visit with a new crowd. BOY's House has a face like Pac-Man's. A lion-faced SUN watches from
  the sky through doughnut clouds.
- **GIRL** — press Start (R) to report how far BOY stretched; it's added to GIRL, who is stretching
  from Earth to the Moon, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto, the Sun and home — the
  route the real GIRL took between 2009 and 2015. She's saved in your browser. One metre of BOY is a
  thousand kilometres of GIRL, so the Moon is a few good sessions away rather than a global effort.
- **No goals, no rules, no timer.** A hand-lettered manual (H) with a pop quiz. Gentle, endless,
  synthesised music (M toggles it).

A gamepad works with the PS3 layout: sticks, L1/R1/L2/R2, D-pad, Start (report), Select (new island),
Triangle (manual).

## Play

From the repo root: `python3 serve.py 8765`, then <http://localhost:8765/nobynobyboy/web/>.
`?mute=1` silences it; `?bg=1` keeps simulating while the tab is hidden (automated playtests).

## Layout

| Path | What |
|------|------|
| `web/main.js` | Setup, input (keyboard, mouse, gamepad), camera, HUD, the manual and report overlays, GIRL's route. |
| `web/boy.js` | BOY: verlet rope physics, eating/digesting/expelling, the tube mesh with colour bands and lumps. |
| `web/world.js` | The island, sky, SUN and clouds; every resident and object builder; wandering/flying/spinning behaviours. |
| `web/audio.js` | WebAudio synth: gulps, pops, jumps, the report jingle and the pentatonic lullaby. |
| `web/vendor/` | `three.module.js` r170 (MIT). |

## Container

`Dockerfile` builds an nginx image serving `web/`; the compose stack mounts it at `/noby-noby-boy/`.
