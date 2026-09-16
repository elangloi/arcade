"""Dev static server for the whole arcade repo (no caching): python3 serve.py [port]
Battle Blitz at /battleblitz/web/, Sandwich Stacker at /sandwichstacker/web/."""
import sys, http.server, functools
from pathlib import Path
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store'); super().end_headers()
    def log_message(self, *a): pass
port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
http.server.ThreadingHTTPServer(('127.0.0.1', port), functools.partial(H, directory=str(Path(__file__).resolve().parent))).serve_forever()
