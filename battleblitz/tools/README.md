# tools

Python pipeline (run with `uv run python <script>` from this folder; `uv` installs the pinned Python):

* `extract.py` — cast members from the ProjectorRays chunk dumps: bitmaps (1/2/4/8/16/32-bit, RLE, palettes, JPEG members), sounds, manifests.
* `sounds.py` — Mac `snd ` resources → WAV.
* `score.py` — Director score (VWSC), labels (VWLB), sprite spans + behaviour params → `assets/score.json`.
* `members.py` — unified member table + film loops (SCVW) → `assets/members.json`.
* `lingo2js.py` — Lingo → JavaScript (`web/game/classes.js`).
* `sheet.py` — contact sheets for eyeballing extracted art. `survey.py` — palette/type survey.
* `serve.py` — no-cache static server for development.

Not checked in (see .gitignore): `ProjectorRays/` (git clone, built with `make` against `deps/boost_1_86_0` headers and `deps/mpg123-install`), `drxtract/` (git clone; used for its palette tables and snd decoder).
