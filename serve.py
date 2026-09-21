"""Dev server for the game cabinets (no caching, no Docker needed): python3 serve.py [port]

Mirrors the proxy's game routes; the Vite front end (npm --prefix frontend run dev) proxies to it:
  /teen-titans-battle-blitz/web/             battleblitz/web/
  /lilo-and-stitch-sandwich-stacker/...      the repo (the game is at .../sandwichstacker/web/)
  /club-penguin-pizzatron/...                the repo (the game is at .../pizzatron/web/)
  /club-penguin-card-jitsu/...               the repo (the game is at .../cardjitsu/web/)
  /noby-noby-boy/web/                        nobynobyboy/web/
The repo folders are also served directly (e.g. /pizzatron/web/).
"""
import sys, http.server, functools
from pathlib import Path

ROOT = Path(__file__).resolve().parent
# slug -> (folder, what the game image has at its root: 'folder' = the game folder itself,
# 'repo' = a mirror of the repo so the game can reach ../../flash/web/player.js)
GAMES = {
    '/teen-titans-battle-blitz': ('battleblitz', 'folder'),
    '/lilo-and-stitch-sandwich-stacker': ('sandwichstacker', 'repo'),
    '/club-penguin-pizzatron': ('pizzatron', 'repo'),
    '/club-penguin-card-jitsu': ('cardjitsu', 'repo'),
    '/noby-noby-boy': ('nobynobyboy', 'folder'),
}


class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store'); super().end_headers()

    def log_message(self, *a): pass

    def do_GET(self):
        path = self.path.split('?', 1)[0]
        for slug, (folder, layout) in GAMES.items():
            if path == slug or path == slug + '/':
                target = f'{slug}/{folder}/web/' if layout == 'repo' else f'{slug}/web/'
                self.send_response(302); self.send_header('Location', target); self.end_headers(); return
            if path.startswith(slug + '/'):
                self.path = path[len(slug):] if layout == 'repo' else '/' + folder + path[len(slug):]
                return super().do_GET()
        if path == '/':
            self.send_response(200); self.send_header('Content-Type', 'text/plain'); self.end_headers()
            self.wfile.write(b'game cabinets only - the arcade front end is at http://localhost:5173/ (npm --prefix frontend run dev)\n'); return
        return super().do_GET()


port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
print(f'arcade at http://localhost:{port}/')
http.server.ThreadingHTTPServer(('127.0.0.1', port), functools.partial(H, directory=str(ROOT))).serve_forever()
