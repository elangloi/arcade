"""Static server for the game with caching disabled: python3 tools/serve.py [port]"""
import sys, http.server, functools
from pathlib import Path
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store'); super().end_headers()
    def log_message(self, *a): pass
port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
root = Path(__file__).resolve().parent.parent
http.server.ThreadingHTTPServer(('127.0.0.1', port), functools.partial(H, directory=str(root))).serve_forever()
