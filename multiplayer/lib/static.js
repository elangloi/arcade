// Tiny static file server: a few mount points, no directory listings, cache headers by kind.
import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import path from 'node:path';

const MIME = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg', '.gif': 'image/gif', '.svg': 'image/svg+xml', '.webp': 'image/webp', '.ico': 'image/x-icon',
  '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.ogg': 'audio/ogg', '.woff': 'font/woff', '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8', '.map': 'application/json',
};

// mounts: [{ url: '/games/battleblitz/assets/', dir: '/abs/path', immutable: true }], longest url first.
export function makeStatic(mounts) {
  const sorted = [...mounts].sort((a, b) => b.url.length - a.url.length);
  return async function serve(req, res, urlPath) {
    if (req.method !== 'GET' && req.method !== 'HEAD') { res.writeHead(405); res.end(); return true; }
    for (const m of sorted) {
      if (!urlPath.startsWith(m.url)) continue;
      let rel;
      try { rel = decodeURIComponent(urlPath.slice(m.url.length)); } catch { res.writeHead(400); res.end('bad path'); return true; }
      if (rel.includes('\0')) { res.writeHead(400); res.end('bad path'); return true; }
      if (rel === '' || rel.endsWith('/')) rel += 'index.html';
      const file = path.resolve(m.dir, rel);
      if (file !== m.dir && !file.startsWith(m.dir + path.sep)) { res.writeHead(403); res.end(); return true; }
      let st;
      try { st = await stat(file); } catch { continue; }
      if (st.isDirectory()) {   // /foo -> /foo/ so relative URLs inside resolve
        res.writeHead(301, { Location: urlPath + '/' }); res.end(); return true;
      }
      const ext = path.extname(file).toLowerCase();
      res.writeHead(200, {
        'Content-Type': MIME[ext] || 'application/octet-stream',
        'Content-Length': st.size,
        'Cache-Control': m.immutable ? 'public, max-age=2592000, immutable' : 'no-cache',
      });
      if (req.method === 'HEAD') { res.end(); return true; }
      createReadStream(file).pipe(res);
      return true;
    }
    return false;
  };
}
