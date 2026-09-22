import path from 'node:path'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'

// Dev: the shell runs on :5173 and proxies the backends the way nginx does in the compose stack:
//   games   -> python3 serve.py 8765   (single-player cabinets, static)
//   /arcade/multiplayer -> npm --prefix multiplayer run dev  (:8766, API + WebSocket + the 2P game)
const GAMES = ['/teen-titans-battle-blitz', '/lilo-and-stitch-sandwich-stacker', '/club-penguin-pizzatron', '/club-penguin-card-jitsu']
const gamesTarget = process.env.GAMES_URL || 'http://localhost:8765'
const mpTarget = process.env.MP_URL || 'http://localhost:8766'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  server: {
    proxy: {
      ...Object.fromEntries(GAMES.map(g => [g, { target: gamesTarget, changeOrigin: true }])),
      '/arcade/multiplayer': { target: mpTarget, changeOrigin: true, ws: true },
    },
  },
})
