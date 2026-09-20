// Battle Blitz, online 2-player edition. This is a fork of battleblitz/web (the single-player
// cabinet is untouched); the multiplayer plumbing lives in mp.js.
import { G, objectp, Behavior } from './runtime/lingo.js';
import { D, go } from './runtime/director.js';
import * as game from './game/classes.js';
import * as mp from './mp.js';

// The original Main.update busy-waits until 33ms have passed; the player already
// ticks at 30fps, so run the body once per tick instead of spinning.
game.Class_Main.prototype.update = function () {
  this.audioMgr.update();
  this.keyMgr.update();
  const i = D.the('milliSeconds');
  G.g.fps = 1.0 / ((i - G.g.frameTimestamp) * 0.001);
  G.g.frameTimestamp = i;
  G.g.frameCount = G.g.frameCount + 1;
  if (objectp(this.screen)) this.screen.update();
};

// The "cartoon_network_enhancements" cast held CN's site plumbing (ad billboard, "Orbit" page
// launcher). Only the frame script on the "Win" label matters: it moves on to the ending.
class LaunchOrbitScript extends Behavior { exitFrame() { go('Win animation'); } }
class BillboardScript extends Behavior { exitFrame() { go(D.the('frame') + 1); } }
game.SCRIPT_MEMBERS['11:14'] = LaunchOrbitScript;
game.SCRIPT_MEMBERS['11:13'] = BillboardScript;

const MOVIE_CASTS = ['hud', 'select_screen', 'misc', 'game_messages', 'versus_screen', 'audio',
  'controls_screen', 'title_screen', 'cartoon_network_enhancements', 'win_screen', 'char_shared'];

async function boot() {
  const canvas = document.getElementById('stage');
  const status = document.getElementById('status');
  const params = new URLSearchParams(location.search);
  await D.init({
    canvas,
    SCRIPTS: game.SCRIPTS,
    SCRIPT_MEMBERS: game.SCRIPT_MEMBERS,
    movie: { prepareMovie: game.prepareMovie, stopMovie: game.stopMovie, prepareFrame: game.prepareFrame, exitFrame: game.exitFrame },
  });
  let done = 0;
  const total = MOVIE_CASTS.length;
  for (const name of MOVIE_CASTS) {
    status.textContent = `Loading ${name}… (${done}/${total})`;
    await D.preloadCast(name);
    done++;
  }
  status.textContent = '';
  window.D = D; window.G = G;   // handy for poking at things from the console
  await mp.install({ session: params.get('session'), match: params.get('match'), mute: params.has('mute') });
  await D.start();
  mp.begin();
}

boot().catch(e => { console.error(e); document.getElementById('status').textContent = 'Failed to start: ' + e.message; });
