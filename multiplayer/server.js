// Multiplayer arcade service: one Node process serving the landing page, the lobby, the
// forked Battle Blitz client, its art, a small JSON API and the matchmaking/lockstep WebSocket.
import { config } from './lib/config.js';
import { createApp } from './lib/app.js';

const app = createApp(config);
app.server.listen(config.port, config.host, () => {
  console.log(`multiplayer arcade on http://localhost:${config.port}${config.basePath}/  (db ${config.dbPath}, assets ${app.assetsDir})`);
});
for (const sig of ['SIGINT', 'SIGTERM']) process.on(sig, () => { app.close(); process.exit(0); });
