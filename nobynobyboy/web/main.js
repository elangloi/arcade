// Noby Noby Boy — a homage. Two sticks, one stretchy BOY, an island of odd residents, and GIRL
// growing across the solar system from everything you report.
import * as THREE from './vendor/three.module.js';
import { World } from './world.js';
import { Boy } from './boy.js';
import { Audio } from './audio.js';

const $ = id => document.getElementById(id);

// ---- GIRL: what BOY reports accumulates here, one metre of BOY = 1000 km of GIRL -------------------
const KM_PER_M = 1000;
const LEGS = [   // her route, in the order the original took: out through the planets, then to the Sun and home
  ['Earth', 'the Moon', 384400], ['the Moon', 'Mars', 78000000], ['Mars', 'Jupiter', 550000000], ['Jupiter', 'Saturn', 650000000],
  ['Saturn', 'Uranus', 1450000000], ['Uranus', 'Neptune', 1600000000], ['Neptune', 'Pluto', 1500000000], ['Pluto', 'the Sun', 5900000000], ['the Sun', 'Earth', 150000000],
];
const girl = {
  get km() { try { return Number(localStorage.getItem('nnb.girl') || 0); } catch (e) { return 0; } },
  set km(v) { try { localStorage.setItem('nnb.girl', String(v)); } catch (e) { } },
  leg() { let rest = this.km; for (const [from, to, d] of LEGS) { if (rest < d) return { from, to, d, done: rest }; rest -= d; } return { from: 'Earth', to: 'everywhere', d: 1, done: 1, complete: true }; },
};
const fmt = n => Math.round(n).toLocaleString('en-US');

// ---- setup ---------------------------------------------------------------------------------------
const canvas = $('c');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(2, window.devicePixelRatio));
renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(50, 1, 0.1, 300);
const world = new World(scene);
world.generate();
const boy = new Boy(scene, world);
const audio = new Audio();
let camYaw = 0, camPitch = 0.62, camDist = 16;
const cam = { pos: new THREE.Vector3(), look: new THREE.Vector3() };

function resize() { const w = window.innerWidth, h = window.innerHeight; renderer.setSize(w, h, false); camera.aspect = w / h; camera.updateProjectionMatrix(); }
window.addEventListener('resize', resize); resize();

// ---- input: keyboard, mouse, gamepad -------------------------------------------------------------
const keys = new Set();
window.addEventListener('keydown', e => {
  if (e.repeat) return;
  keys.add(e.code); audio.ensure();
  if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.code)) e.preventDefault();
  if (e.code === 'KeyE') eating = true;
  if (e.code === 'Space') jumpQueued = true;
  if (e.code === 'KeyQ') expel();
  if (e.code === 'KeyH' || e.code === 'Slash') toggle('manual');
  if (e.code === 'KeyR') openReport();
  if (e.code === 'KeyN') newIsland();
  if (e.code === 'KeyM') toast(audio.toggleMusic() ? 'music on' : 'music off');
  if (e.code === 'KeyC') { boy.banded = true; boy.colorShift -= 1; }
  if (e.code === 'KeyV') { boy.banded = true; boy.colorShift += 1; }
  if (e.code === 'Escape') { closeAll(); }
});
window.addEventListener('keyup', e => { keys.delete(e.code); if (e.code === 'KeyE') eating = false; });
window.addEventListener('blur', () => keys.clear());
let dragging = false, lastX = 0, lastY = 0;
canvas.addEventListener('mousedown', e => { dragging = true; lastX = e.clientX; lastY = e.clientY; audio.ensure(); });
window.addEventListener('mouseup', () => dragging = false);
window.addEventListener('mousemove', e => { if (!dragging) return; camYaw -= (e.clientX - lastX) * 0.006; camPitch = Math.max(0.25, Math.min(1.2, camPitch + (e.clientY - lastY) * 0.004)); lastX = e.clientX; lastY = e.clientY; });
canvas.addEventListener('wheel', e => { camDist = Math.max(8, Math.min(40, camDist + e.deltaY * 0.02)); }, { passive: true });

let eating = false, jumpQueued = false;
const padPrev = {};
function readInput() {
  const inp = { head: { x: 0, y: 0 }, butt: { x: 0, y: 0 }, jump: false, jumpButt: false, float: false };
  const k = c => keys.has(c) ? 1 : 0;
  inp.head.x = k('KeyD') - k('KeyA'); inp.head.y = k('KeyS') - k('KeyW');
  inp.butt.x = k('ArrowRight') - k('ArrowLeft'); inp.butt.y = k('ArrowDown') - k('ArrowUp');
  inp.jump = jumpQueued; inp.jumpButt = jumpQueued; jumpQueued = false;
  inp.float = keys.has('ShiftLeft') || keys.has('ShiftRight');
  if (keys.has('BracketLeft')) camYaw += 0.03; if (keys.has('BracketRight')) camYaw -= 0.03;
  // gamepad: left stick head, right stick butt, L1 jump, R1 float, L2 eat, R2 pop, d-pad colours, Start report
  const pad = (navigator.getGamepads ? navigator.getGamepads() : [])[0];
  if (pad) {
    const dz = v => Math.abs(v) < 0.15 ? 0 : v;
    inp.head.x += dz(pad.axes[0] || 0); inp.head.y += dz(pad.axes[1] || 0);
    inp.butt.x += dz(pad.axes[2] || 0); inp.butt.y += dz(pad.axes[3] || 0);
    const b = i => !!(pad.buttons[i] && pad.buttons[i].pressed);
    const pressed = i => { const now = b(i); const was = padPrev[i]; padPrev[i] = now; return now && !was; };
    if (pressed(4)) { inp.jump = true; inp.jumpButt = true; } if (b(5)) inp.float = true;
    eating = eating || b(6);
    if (pressed(7)) expel();
    if (pressed(14)) { boy.banded = true; boy.colorShift -= 1; } if (pressed(15)) { boy.banded = true; boy.colorShift += 1; }
    if (pressed(9)) openReport(); if (pressed(3)) toggle('manual'); if (pressed(8)) newIsland();
    if (b(6) || b(4) || b(5)) audio.ensure();
    if (!b(6) && !keys.has('KeyE')) eating = false;
  }
  for (const s of [inp.head, inp.butt]) { const l = Math.hypot(s.x, s.y); if (l > 1) { s.x /= l; s.y /= l; } }
  return inp;
}

// ---- overlays ------------------------------------------------------------------------------------
function toggle(id) { const el = $(id); el.classList.toggle('show'); }
function closeAll() { for (const id of ['manual', 'report']) $(id).classList.remove('show'); }
$('closeManual').onclick = () => toggle('manual');
$('closeReport').onclick = () => toggle('report');
let toastT = null;
function toast(msg) { const t = $('toast'); t.textContent = msg; t.classList.add('show'); clearTimeout(toastT); toastT = setTimeout(() => t.classList.remove('show'), 1800); }

function openReport() {
  const m = boy.stretched;
  girl.km += m * KM_PER_M;
  boy.stretched = 0;
  audio.report();
  $('rLen').textContent = m.toFixed(1);
  const leg = girl.leg();
  $('gLen').textContent = fmt(girl.km);
  $('gNext').textContent = leg.to; $('gFrom').textContent = leg.from; $('gTo').textContent = `${leg.to} · ${fmt(leg.d)} km`;
  $('gBar').style.width = `${Math.min(100, leg.done / leg.d * 100)}%`;
  $('gNote').textContent = leg.complete ? 'GIRL has been everywhere and come home. She would like a snack.' : `${fmt(leg.d - leg.done)} km to go. Thank you, BOY.`;
  $('report').classList.add('show');
}

function newIsland() {
  closeAll();
  world.generate();
  boy.reset(world.homeDoor());
  boy.stomach = [];
  toast('a new island!');
}

function expel() {
  const o = boy.expel();
  if (o) { audio.pop(); toast(`BOY popped out a ${o.kind}`); }
}

// ---- the loop ------------------------------------------------------------------------------------
boy.reset(world.homeDoor());
let last = performance.now(), t = 0, stretchTick = 0;
let rafPending = false;
function frame(now) {
  if (!rafPending) { rafPending = true; requestAnimationFrame(n => { rafPending = false; frame(n); }); }
  const dt = Math.min(0.05, (now - last) / 1000); last = now; t += dt;
  const paused = $('manual').classList.contains('show') || $('report').classList.contains('show');
  const inp = paused ? { head: { x: 0, y: 0 }, butt: { x: 0, y: 0 } } : readInput();
  if (paused) jumpQueued = false;
  // physics in fixed sub-steps for stability
  const steps = 3; let fell = null;
  for (let i = 0; i < steps; i++) fell = boy.step(dt / steps, inp, camYaw) || fell;
  if (!paused && inp.jump) audio.jump();
  if (fell) { audio.fall(); toast('BOY fell off the island. Home you go.'); boy.reset(world.homeDoor()); }
  if (eating && !paused) { const o = boy.tryEat(world.edibles()); if (o) { audio.eat(); toast(`BOY ate a ${o.kind}`); } }
  // a little stretchy sound while lengthening
  if (boy.length > boy.lastStretchSound + 0.8) { audio.stretch(); boy.lastStretchSound = boy.length; } else if (boy.length < boy.lastStretchSound - 2) boy.lastStretchSound = boy.length;
  world.update(dt, t);
  boy.render(t);
  // camera: orbit the middle of BOY, backing off as he stretches
  const mid = boy.mid();
  const spread = boy.head.distanceTo(boy.butt);
  const dist = camDist + spread * 0.55;
  const target = new THREE.Vector3(Math.sin(camYaw) * Math.cos(camPitch), Math.sin(camPitch), Math.cos(camYaw) * Math.cos(camPitch)).multiplyScalar(dist).add(mid);
  cam.pos.lerp(target, 0.08); cam.look.lerp(mid, 0.12);
  camera.position.copy(cam.pos); camera.lookAt(cam.look);
  world.dome.position.copy(camera.position);
  // HUD
  $('len').textContent = boy.length.toFixed(1);
  $('total').textContent = boy.stretched.toFixed(1);
  $('eaten').textContent = boy.eaten;
  renderer.render(scene, camera);
}
boy.lastStretchSound = 0;
requestAnimationFrame(frame);
// ?bg=1: keep simulating when the tab is hidden and rAF stops (used for automated playtests)
if (new URLSearchParams(location.search).has('bg')) setInterval(() => { if (performance.now() - last > 100) frame(performance.now()); }, 33);
window.G = { boy, world, girl, camera, keys, eat: v => { eating = v; }, setCam: (y, p) => { camYaw = y; camPitch = p; } };
