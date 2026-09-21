# frontend — the arcade shell

React 19 + TypeScript + Vite, Tailwind v4, shadcn/ui (radix, "nova" preset) restyled with the
arcade palette and Fredoka. It is the only thing a player ever navigates: the front of house, the
single-player and multiplayer floors, the Battle Blitz 2P lobby, and a **frame** that shows whichever
cabinet is playing (the games stay separate static apps behind the proxy).

```
src/App.tsx                   routes + the shell (nav bar, main, footer)
src/components/ArcadeNav.tsx  the dropdown (Arcade ▾ → Front of house / Single player ▸ games / Multiplayer ▸ games),
                              breadcrumbs, the coin badge
src/components/Cabinet.tsx    the cabinet cards + attract-mode art
src/components/GameFrame.tsx  the bezel + <iframe>, wired to the bridge
src/components/Deco.tsx       claw, stars, hearts, page titles
src/pages/                    Home, SinglePlayer, Multiplayer (floor), Lobby, Play, MultiplayerPlay
src/lib/games.ts              the catalogue: one entry per cabinet (mode, route, frame src, help line)
src/lib/mp.ts                 lobby client (session + WebSocket) for the multiplayer service
src/lib/bridge.ts             postMessage contract between the shell and a framed game
src/lib/coins.ts              the coin wallet seam (see below)
src/index.css                 theme tokens, arcade CSS pieces, cabinet/machine/frame styles
public/                       fonts, cabinet art
Dockerfile                    builds dist/ and bakes it into the nginx proxy image (arcade/proxy)
```

Routes: `/` · `/single` · `/single/:slug` · `/multiplayer` · `/multiplayer/battleblitz` (lobby) ·
`/multiplayer/battleblitz/play?match=&session=` (the fight).

## Dev

Three processes, then <http://localhost:5173/>:

```bash
python3 serve.py 8765                 # the single-player cabinets (static)
npm --prefix multiplayer run dev      # the multiplayer service on :8766
npm --prefix frontend run dev         # Vite on :5173, proxies the two above like nginx does
```

`.claude/launch.json` has all three. `npm --prefix frontend run build` type-checks and bundles.

## Adding a cabinet

Add a `location` block in `compose/nginx/conf.d/arcade.conf` and a service in the compose file as
before, then one entry in `src/lib/games.ts` — the menu, the floors and the frame route come from it.

## The frame bridge

A framed game may `postMessage` to the shell (same origin): `arcade:ready`, `arcade:navigate {to}`,
`arcade:hud {…}` (the 2P game sends its bar + help line so the shell draws them under the frame),
and `arcade:coins:earn|spend {game, amount, reason}`. The shell answers `arcade:coins:balance`.
Only the 2P Battle Blitz client uses it today; the single-player cabinets are framed untouched.

## Coins (foundation only)

`src/lib/coins.ts` defines `CoinProvider` (balance / earn / spend / history / subscribe) and ships a
`LocalCoinProvider` (one wallet per browser in localStorage). The nav shows the balance; nothing earns
coins yet — `arcade:coins:*` messages from games are logged, not credited (`CREDIT_FROM_GAMES`).

The intended next step, when it's time: a server-side wallet in the multiplayer service (SQLite
`wallets` + `ledger` tables keyed by a player identity, endpoints under `/arcade/multiplayer/api/coins`,
the match result handler minting a KO bonus), a `ServerCoinProvider` implementing the same interface,
and games calling `earn` through the bridge with the shell forwarding to the server. Nothing above
`coins.ts` needs to change for that.
