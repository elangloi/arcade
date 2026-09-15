import { G, objectp, Behavior } from './runtime/lingo.js';
import { D, go } from './runtime/director.js';
import * as game from './game/classes.js';

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
  await D.init({
    canvas,
    SCRIPTS: game.SCRIPTS,
    SCRIPT_MEMBERS: game.SCRIPT_MEMBERS,
    movie: { prepareMovie: game.prepareMovie, stopMovie: game.stopMovie, prepareFrame: game.prepareFrame, exitFrame: game.exitFrame },
  });
  // Everything the internal movie shipped with is loaded up front (the .dcr was one download);
  // the character casts stream in later exactly as the original did.
  let done = 0;
  const total = MOVIE_CASTS.length;
  for (const name of MOVIE_CASTS) {
    status.textContent = `Loading ${name}… (${done}/${total})`;
    await D.preloadCast(name);
    done++;
  }
  status.textContent = '';
  window.D = D; window.G = G;   // handy for poking at things from the console
  await D.start();
}

boot().catch(e => { console.error(e); document.getElementById('status').textContent = 'Failed to start: ' + e.message; });

// Debug helper: AI-vs-AI soak test across matchups. Usage from the console:
//   soak([[1,6],[2,7]], 20)   -> titan/villain id pairs, seconds per match
window.soak = async function (pairs, seconds = 20, asVillains = false) {
  const AI = { 1: 'Class_RobinAI', 2: 'Class_RavenAI', 3: 'Class_CyborgAI', 4: 'Class_StarfireAI', 5: 'Class_BeastboyAI',
    6: 'Class_JinxAI', 7: 'Class_GizmoAI', 8: 'Class_MammothAI', 9: 'Class_CinderblockAI', 10: 'Class_PlasmusAI' };
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const report = [];
  for (const [t, v] of pairs) {
    const g = G.g;
    g.difficulty = 3; g.playMode = asVillains ? 2 : 1; g.titanID = t; g.villainID = v;
    g.playerID = asVillains ? v : t; g.enemyID = asVillains ? t : v;
    D.errors.length = 0;
    g.goFrame = D.label('SCREEN_VERSUS');
    const t0 = performance.now();
    while (!(g.game && g.game.gameStage === 2) && performance.now() - t0 < 30000) await sleep(200);
    if (g.game && g.game.gameStage === 2) {
      g.game.playerAdapter = new G.g.classes[AI[g.playerID]](g.game.player);
      g.game.playerAdapter.reset();
      await sleep(seconds * 1000);
    }
    report.push({ t, v, stage: g.game && g.game.gameStage, errors: D.errors.slice(0, 3) });
    console.log('soak', t, v, D.errors.length, 'errors');
  }
  return report;
};
