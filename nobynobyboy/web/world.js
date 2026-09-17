// The floating island and everything that lives on it: BOY's house (it has a face), the lion-faced
// SUN and doughnut clouds in the sky, and a fresh random crowd of residents each visit — odd little
// people, chickens, cows, land sharks, toucans, hover cars, spinning tops, donuts, robots, trees.
import * as THREE from './vendor/three.module.js';

const INK = 0x2a2440;
const rnd = (a, b) => a + Math.random() * (b - a);
const pick = arr => arr[Math.floor(Math.random() * arr.length)];
const toon = c => new THREE.MeshToonMaterial({ color: c });
const PALETTE = [0xff6fae, 0xffd23f, 0x5ec8ff, 0xff9f43, 0xc77dff, 0x7ed957, 0xff5e5e, 0x4dd0c4, 0xf7f7f7];
const SKIN = [0xffd9b3, 0xf1c27d, 0xc68642, 0x8d5524, 0xffe0bd];

// ---- things that live on the island -------------------------------------------------------------
class Thing {
  constructor(world, kind, mesh, size, opts = {}) {
    this.world = world; this.kind = kind; this.mesh = mesh; this.size = size;
    this.fixed = !!opts.fixed; this.flying = !!opts.flying; this.speed = opts.speed || 0;
    this.eaten = false; this.vel = new THREE.Vector3(); this.airborne = false;
    this.target = null; this.pause = rnd(0, 2); this.phase = rnd(0, 6.28);
    this.baseY = opts.baseY || 0;
    world.scene.add(mesh);
  }
  position() { return this.mesh.position; }
  eat() { this.eaten = true; this.mesh.visible = false; }
  expel(pos, vel) { this.eaten = false; this.mesh.visible = true; this.mesh.position.copy(pos); this.vel.copy(vel); this.airborne = true; }
  update(dt, t) {
    const p = this.mesh.position;
    if (this.airborne) {   // popped out of BOY: fly, bounce once, settle
      this.vel.y -= 25 * dt; p.addScaledVector(this.vel, dt);
      this.mesh.rotation.x += this.vel.length() * dt * 0.5;
      const gy = this.world.groundHeight(p.x, p.z);
      if (gy !== null && p.y <= gy + this.baseY) { p.y = gy + this.baseY; this.airborne = false; this.vel.set(0, 0, 0); this.mesh.rotation.set(0, this.mesh.rotation.y, 0); }
      if (p.y < -30) { this.world.respawn(this); }
      return;
    }
    if (this.fixed || !this.speed) { if (this.spin) this.mesh.rotation.y += this.spin * dt; if (this.wobble) this.mesh.rotation.z = Math.sin(t * 3 + this.phase) * 0.12; return; }
    if (this.flying) {   // toucans circle
      const r = 9 + Math.sin(this.phase) * 3, a = t * 0.35 + this.phase;
      const cx = Math.cos(this.phase * 3) * 8, cz = Math.sin(this.phase * 2) * 6;
      const nx = cx + Math.cos(a) * r, nz = cz + Math.sin(a) * r * 0.7;
      this.mesh.rotation.y = Math.atan2(nx - p.x, nz - p.z) + Math.PI;
      p.set(nx, 3.5 + Math.sin(t * 1.3 + this.phase) * 1.2, nz);
      if (this.flap) this.flap.forEach((w, i) => w.rotation.z = (i ? -1 : 1) * Math.sin(t * 12) * 0.7);
      return;
    }
    // wanderers: pick somewhere on the island, walk there, pause, repeat
    if (this.pause > 0) { this.pause -= dt; if (this.bob) this.mesh.position.y = this.baseY; return; }
    if (!this.target) { this.target = new THREE.Vector3(rnd(-this.world.w / 2 + 2, this.world.w / 2 - 2), 0, rnd(-this.world.d / 2 + 2, this.world.d / 2 - 2)); }
    const to = this.target.clone().sub(p); to.y = 0;
    if (to.length() < 0.5) { this.target = null; this.pause = rnd(0.5, 3); return; }
    to.normalize();
    p.addScaledVector(to, this.speed * dt);
    const gy = this.world.groundHeight(p.x, p.z); p.y = (gy === null ? 0 : gy) + this.baseY + (this.bob ? Math.abs(Math.sin(t * 9 + this.phase)) * 0.12 : 0);
    this.mesh.rotation.y = Math.atan2(to.x, to.z);
    if (this.legs) this.legs.forEach((l, i) => l.rotation.x = Math.sin(t * 10 + i * Math.PI) * 0.5);
  }
}

// ---- builders ----------------------------------------------------------------------------------
function person() {
  const g = new THREE.Group(); const c = pick(PALETTE), skin = pick(SKIN);
  const body = new THREE.Mesh(new THREE.CapsuleGeometry(0.28, 0.5, 4, 10), toon(c)); body.position.y = 0.55; body.castShadow = true; g.add(body);
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.34, 16, 12), toon(skin)); head.position.y = 1.25; head.castShadow = true; g.add(head);
  const eyeM = new THREE.MeshBasicMaterial({ color: INK });
  for (const x of [-0.12, 0.12]) { const e = new THREE.Mesh(new THREE.SphereGeometry(0.05, 8, 6), eyeM); e.position.set(x, 1.3, 0.3); g.add(e); }
  if (Math.random() < 0.3) { const chin = new THREE.Mesh(new THREE.SphereGeometry(0.16, 10, 8), toon(skin)); chin.position.set(0, 1.0, 0.24); g.add(chin); }   // the one with the chin
  if (Math.random() < 0.4) { const hat = new THREE.Mesh(new THREE.ConeGeometry(0.3, 0.45, 12), toon(pick(PALETTE))); hat.position.y = 1.75; g.add(hat); }
  const legs = [];
  for (const x of [-0.13, 0.13]) { const l = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 0.35, 8), toon(INK)); l.position.set(x, 0.17, 0); g.add(l); legs.push(l); }
  g.legs = legs;
  return [g, 0.7, { speed: rnd(1.2, 2.2), bob: true }];
}
function chicken() {
  const g = new THREE.Group();
  const body = new THREE.Mesh(new THREE.SphereGeometry(0.32, 14, 10), toon(0xffffff)); body.scale.set(1, 0.85, 1.25); body.position.y = 0.42; body.castShadow = true; g.add(body);
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.17, 12, 8), toon(0xffffff)); head.position.set(0, 0.8, 0.28); g.add(head);
  const comb = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.16, 0.2), toon(0xff3b3b)); comb.position.set(0, 0.98, 0.26); g.add(comb);
  const beak = new THREE.Mesh(new THREE.ConeGeometry(0.07, 0.2, 8), toon(0xffb000)); beak.position.set(0, 0.78, 0.5); beak.rotation.x = Math.PI / 2; g.add(beak);
  const eyeM = new THREE.MeshBasicMaterial({ color: INK });
  for (const x of [-0.08, 0.08]) { const e = new THREE.Mesh(new THREE.SphereGeometry(0.03, 6, 5), eyeM); e.position.set(x, 0.84, 0.42); g.add(e); }
  return [g, 0.45, { speed: rnd(2, 3.5), bob: true }];
}
function cow() {
  const g = new THREE.Group();
  const body = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.7, 1.5), toon(0xf7f7f7)); body.position.y = 0.8; body.castShadow = true; g.add(body);
  for (let i = 0; i < 3; i++) { const s = new THREE.Mesh(new THREE.BoxGeometry(rnd(0.25, 0.45), 0.72, rnd(0.3, 0.5)), toon(INK)); s.position.set(rnd(-0.3, 0.3), 0.8, rnd(-0.5, 0.5)); g.add(s); }
  const head = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.45, 0.5), toon(0xf7f7f7)); head.position.set(0, 1.05, 0.95); g.add(head);
  const nose = new THREE.Mesh(new THREE.BoxGeometry(0.4, 0.22, 0.2), toon(0xffb3c6)); nose.position.set(0, 0.95, 1.22); g.add(nose);
  const legs = [];
  for (const [x, z] of [[-0.3, 0.5], [0.3, 0.5], [-0.3, -0.5], [0.3, -0.5]]) { const l = new THREE.Mesh(new THREE.CylinderGeometry(0.09, 0.09, 0.5, 8), toon(0xf7f7f7)); l.position.set(x, 0.25, z); g.add(l); legs.push(l); }
  g.legs = legs;
  return [g, 1.1, { speed: rnd(0.5, 1) }];
}
function shark() {   // a land shark, as is traditional
  const g = new THREE.Group();
  const body = new THREE.Mesh(new THREE.SphereGeometry(0.5, 14, 10), toon(0x8fa3b8)); body.scale.set(0.8, 0.8, 2.2); body.position.y = 0.42; body.castShadow = true; g.add(body);
  const belly = new THREE.Mesh(new THREE.SphereGeometry(0.42, 12, 8), toon(0xf1f5f9)); belly.scale.set(0.8, 0.5, 2); belly.position.y = 0.25; g.add(belly);
  const fin = new THREE.Mesh(new THREE.ConeGeometry(0.28, 0.6, 3), toon(0x8fa3b8)); fin.position.set(0, 1.05, -0.1); g.add(fin);
  const tail = new THREE.Mesh(new THREE.ConeGeometry(0.3, 0.5, 3), toon(0x8fa3b8)); tail.position.set(0, 0.55, -1.25); tail.rotation.x = Math.PI; g.add(tail);
  const eyeM = new THREE.MeshBasicMaterial({ color: INK });
  for (const x of [-0.25, 0.25]) { const e = new THREE.Mesh(new THREE.SphereGeometry(0.06, 6, 5), eyeM); e.position.set(x, 0.55, 0.8); g.add(e); }
  const teeth = new THREE.Mesh(new THREE.TorusGeometry(0.22, 0.05, 6, 14, Math.PI), new THREE.MeshBasicMaterial({ color: 0xffffff })); teeth.position.set(0, 0.28, 1.05); teeth.rotation.z = Math.PI; g.add(teeth);
  return [g, 1.2, { speed: rnd(0.8, 1.6) }];
}
function toucan() {
  const g = new THREE.Group();
  const body = new THREE.Mesh(new THREE.SphereGeometry(0.3, 12, 8), toon(INK)); body.scale.set(1, 1, 1.4); g.add(body);
  const chest = new THREE.Mesh(new THREE.SphereGeometry(0.2, 10, 8), toon(0xffd23f)); chest.position.set(0, -0.05, 0.28); g.add(chest);
  const beak = new THREE.Mesh(new THREE.ConeGeometry(0.14, 0.7, 8), toon(0xff9f43)); beak.position.set(0, 0.05, 0.7); beak.rotation.x = Math.PI / 2; g.add(beak);
  const eye = new THREE.Mesh(new THREE.SphereGeometry(0.06, 6, 5), new THREE.MeshBasicMaterial({ color: 0xffffff })); eye.position.set(0.18, 0.12, 0.3); g.add(eye);
  g.flap = [];
  for (const s of [-1, 1]) { const w = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.06, 0.35), toon(INK)); w.position.set(s * 0.45, 0.05, 0); w.geometry.translate(s * 0.3, 0, 0); g.add(w); g.flap.push(w); }
  if (Math.random() < 0.5) { const [rider] = person(); rider.scale.setScalar(0.55); rider.position.set(0, 0.25, -0.1); g.add(rider); }   // someone jockeying around on it
  return [g, 0.8, { flying: true }];
}
function hovercar() {
  const g = new THREE.Group(); const c = pick(PALETTE);
  const body = new THREE.Mesh(new THREE.CapsuleGeometry(0.5, 1.4, 6, 12), toon(c)); body.rotation.z = Math.PI / 2; body.position.y = 0.9; body.castShadow = true; g.add(body);
  const dome = new THREE.Mesh(new THREE.SphereGeometry(0.45, 14, 10, 0, Math.PI * 2, 0, Math.PI / 2), new THREE.MeshToonMaterial({ color: 0xbfefff, transparent: true, opacity: 0.6 })); dome.position.set(0, 1.15, 0.2); g.add(dome);
  const [driver] = person(); driver.scale.setScalar(0.5); driver.position.set(0, 0.85, 0.2); g.add(driver);
  const glow = new THREE.Mesh(new THREE.CircleGeometry(0.6, 16), new THREE.MeshBasicMaterial({ color: 0x5ec8ff, transparent: true, opacity: 0.35 })); glow.rotation.x = -Math.PI / 2; glow.position.y = 0.06; g.add(glow);
  return [g, 1.3, { speed: rnd(3, 4.5), baseY: 0.35 }];
}
function walker() {   // a mechanical walker with a pilot
  const g = new THREE.Group();
  const cab = new THREE.Mesh(new THREE.BoxGeometry(1, 0.8, 0.9), toon(0xb0b8c4)); cab.position.y = 1.7; cab.castShadow = true; g.add(cab);
  const [pilot] = person(); pilot.scale.setScalar(0.45); pilot.position.set(0, 2.1, 0); g.add(pilot);
  const legs = [];
  for (const x of [-0.45, 0.45]) { const l = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.16, 1.4, 8), toon(0x6b7280)); l.position.set(x, 0.7, 0); l.geometry.translate(0, -0.6, 0); l.position.y = 1.3; g.add(l); legs.push(l); }
  g.legs = legs;
  return [g, 1.4, { speed: rnd(0.8, 1.4) }];
}
function robot() {
  const g = new THREE.Group(); const c = pick([0xb0b8c4, 0xff5e5e, 0x5ec8ff]);
  const body = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.8, 0.5), toon(c)); body.position.y = 0.75; body.castShadow = true; g.add(body);
  const head = new THREE.Mesh(new THREE.CylinderGeometry(0.3, 0.3, 0.4, 12), toon(c)); head.position.y = 1.4; g.add(head);
  const ant = new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.03, 0.4, 6), toon(INK)); ant.position.y = 1.8; g.add(ant);
  const bulb = new THREE.Mesh(new THREE.SphereGeometry(0.08, 8, 6), new THREE.MeshBasicMaterial({ color: 0xff3b3b })); bulb.position.y = 2.0; g.add(bulb);
  const eyeM = new THREE.MeshBasicMaterial({ color: 0x5ec8ff });
  for (const x of [-0.12, 0.12]) { const e = new THREE.Mesh(new THREE.BoxGeometry(0.1, 0.1, 0.05), eyeM); e.position.set(x, 1.45, 0.3); g.add(e); }
  const legs = [];
  for (const x of [-0.2, 0.2]) { const l = new THREE.Mesh(new THREE.BoxGeometry(0.2, 0.4, 0.25), toon(INK)); l.position.set(x, 0.2, 0); g.add(l); legs.push(l); }
  g.legs = legs;
  return [g, 0.8, { speed: rnd(0.6, 1.2) }];
}
function donut() {
  const g = new THREE.Group();
  const d = new THREE.Mesh(new THREE.TorusGeometry(0.6, 0.28, 12, 24), toon(0xd9a066)); d.rotation.x = Math.PI / 2; d.position.y = 0.3; d.castShadow = true; g.add(d);
  const ice = new THREE.Mesh(new THREE.TorusGeometry(0.6, 0.29, 12, 24, Math.PI * 2), toon(pick([0xff6fae, 0xc77dff, 0x8b5a2b]))); ice.rotation.x = Math.PI / 2; ice.position.y = 0.36; ice.scale.set(1, 1, 0.5); g.add(ice);
  for (let i = 0; i < 12; i++) { const s = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.04, 0.16), toon(pick(PALETTE))); const a = rnd(0, 6.28), r = rnd(0.35, 0.85); s.position.set(Math.cos(a) * r, 0.62, Math.sin(a) * r); s.rotation.y = rnd(0, 3); g.add(s); }
  return [g, 0.9, {}];
}
function top() {
  const g = new THREE.Group(); const c = pick(PALETTE);
  const cone = new THREE.Mesh(new THREE.ConeGeometry(0.55, 0.9, 16), toon(c)); cone.rotation.x = Math.PI; cone.position.y = 0.45; cone.castShadow = true; g.add(cone);
  const disk = new THREE.Mesh(new THREE.CylinderGeometry(0.55, 0.45, 0.25, 16), toon(pick(PALETTE))); disk.position.y = 1.0; g.add(disk);
  const stem = new THREE.Mesh(new THREE.CylinderGeometry(0.07, 0.07, 0.5, 8), toon(INK)); stem.position.y = 1.35; g.add(stem);
  g.userData.spin = rnd(4, 9);
  return [g, 0.8, { spin: true }];
}
function tree() {
  const g = new THREE.Group(); const h = rnd(1.4, 2.4);
  const trunk = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.25, h, 8), toon(0x8b5a2b)); trunk.position.y = h / 2; trunk.castShadow = true; g.add(trunk);
  const leaf = new THREE.Mesh(Math.random() < 0.5 ? new THREE.SphereGeometry(rnd(0.9, 1.4), 12, 9) : new THREE.ConeGeometry(rnd(0.9, 1.3), rnd(1.6, 2.4), 10), toon(pick([0x7ed957, 0x4dd0c4, 0xa3e635, 0xff9f43]))); leaf.position.y = h + 0.6; leaf.castShadow = true; g.add(leaf);
  return [g, 1.8, {}];
}
function house(world, boyHome = false) {
  const g = new THREE.Group(); const c = boyHome ? 0xffd23f : pick(PALETTE); const w = boyHome ? 3.2 : rnd(2, 3), d = boyHome ? 3 : rnd(2, 3), h = boyHome ? 2.6 : rnd(1.8, 2.8);
  const box = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), toon(c)); box.position.y = h / 2; box.castShadow = true; box.receiveShadow = true; g.add(box);
  const roof = new THREE.Mesh(new THREE.ConeGeometry(Math.max(w, d) * 0.8, 1.4, 4), toon(boyHome ? 0xff5e5e : pick(PALETTE))); roof.position.y = h + 0.7; roof.rotation.y = Math.PI / 4; roof.castShadow = true; g.add(roof);
  const eyeM = new THREE.MeshBasicMaterial({ color: INK }), white = new THREE.MeshBasicMaterial({ color: 0xffffff });
  // windows as eyes, the door as a mouth — BOY's house grins like Pac-Man's
  for (const x of [-w * 0.25, w * 0.25]) {
    const win = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.5, 0.05), white); win.position.set(x, h * 0.65, d / 2 + 0.02); g.add(win);
    if (boyHome) { const pupil = new THREE.Mesh(new THREE.BoxGeometry(0.2, 0.2, 0.06), eyeM); pupil.position.set(x + 0.08, h * 0.62, d / 2 + 0.05); g.add(pupil); }
  }
  const door = new THREE.Mesh(new THREE.BoxGeometry(boyHome ? 1.4 : 0.6, boyHome ? 0.7 : 1.0, 0.05), eyeM); door.position.set(0, boyHome ? 0.45 : 0.5, d / 2 + 0.02); g.add(door);
  if (boyHome) { const nose = new THREE.Mesh(new THREE.ConeGeometry(0.15, 0.9, 8), toon(0xff9f43)); nose.position.set(0, h * 0.5, d / 2 + 0.4); nose.rotation.x = Math.PI / 2; g.add(nose); }
  g.userData.radius = Math.max(w, d) * 0.55;
  return [g, 3, { fixed: true }];
}

// ---- the world ---------------------------------------------------------------------------------
export class World {
  constructor(scene) {
    this.scene = scene; this.things = []; this.w = 44; this.d = 32;
    this.buildSky();
  }

  groundHeight(x, z) { return (Math.abs(x) <= this.w / 2 && Math.abs(z) <= this.d / 2) ? 0 : null; }

  // keep BOY out of the solid things (houses, trees)
  pushOut(p, r) {
    for (const t of this.things) {
      if (t.eaten || !(t.fixed || t.kind === 'tree')) continue;
      const q = t.mesh.position; const rad = (t.mesh.userData.radius || 0.3) + r;
      const dx = p.x - q.x, dz = p.z - q.z; const d = Math.hypot(dx, dz);
      const top = t.kind === 'house' ? 2.2 : 1.2;
      if (d < rad && p.y < q.y + top) { const push = (rad - d) / (d || 1); p.x += dx * push; p.z += dz * push; }
    }
  }

  buildSky() {
    const s = this.scene;
    s.background = new THREE.Color(0x9fd6ff);
    s.fog = new THREE.Fog(0x9fd6ff, 60, 140);
    // gradient sky dome
    const dome = new THREE.Mesh(new THREE.SphereGeometry(120, 24, 12), new THREE.ShaderMaterial({
      side: THREE.BackSide, depthWrite: false,
      uniforms: { top: { value: new THREE.Color(0x4fa8ff) }, bottom: { value: new THREE.Color(0xd8f1ff) } },
      vertexShader: 'varying float h; void main(){ h = normalize(position).y; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }',
      fragmentShader: 'uniform vec3 top; uniform vec3 bottom; varying float h; void main(){ gl_FragColor = vec4(mix(bottom, top, smoothstep(-0.1, 0.6, h)), 1.0); }',
    }));
    s.add(dome); this.dome = dome;
    s.add(new THREE.HemisphereLight(0xdff4ff, 0x8fbf6a, 0.9));
    const sun = new THREE.DirectionalLight(0xfff3d0, 1.6); sun.position.set(30, 50, 20); sun.castShadow = true;
    sun.shadow.mapSize.set(2048, 2048); Object.assign(sun.shadow.camera, { left: -30, right: 30, top: 25, bottom: -25, near: 10, far: 120 });
    s.add(sun);
    // the SUN, a giant lion-ish face peering down from space
    const sunG = new THREE.Group();
    const disc = new THREE.Mesh(new THREE.SphereGeometry(7, 24, 16), new THREE.MeshBasicMaterial({ color: 0xffd23f, fog: false })); sunG.add(disc);
    for (let i = 0; i < 16; i++) { const spike = new THREE.Mesh(new THREE.ConeGeometry(1.4, 3.6, 5), new THREE.MeshBasicMaterial({ color: 0xff9f43, fog: false })); const a = i / 16 * Math.PI * 2; spike.position.set(Math.cos(a) * 8.2, Math.sin(a) * 8.2, 0); spike.rotation.z = a - Math.PI / 2; sunG.add(spike); }
    const inkM = new THREE.MeshBasicMaterial({ color: INK, fog: false });
    for (const x of [-2.4, 2.4]) { const e = new THREE.Mesh(new THREE.SphereGeometry(0.9, 12, 8), inkM); e.position.set(x, 1.6, 6.6); sunG.add(e); }
    const nose = new THREE.Mesh(new THREE.SphereGeometry(1.1, 12, 8), new THREE.MeshBasicMaterial({ color: 0xff6fae, fog: false })); nose.position.set(0, -0.3, 7.0); sunG.add(nose);
    const smile = new THREE.Mesh(new THREE.TorusGeometry(2.2, 0.32, 8, 24, Math.PI), inkM); smile.position.set(0, -1.4, 6.8); smile.rotation.z = Math.PI; sunG.add(smile);
    for (const s2 of [-1, 1]) for (let k = 0; k < 3; k++) { const w = new THREE.Mesh(new THREE.BoxGeometry(3.5, 0.12, 0.1), inkM); w.position.set(s2 * 3.6, -1.2 + k * 0.6, 6.6); w.rotation.z = s2 * (k - 1) * 0.25; sunG.add(w); }
    sunG.position.set(-60, 24, -80); sunG.lookAt(0, 0, 0); s.add(sunG); this.sun = sunG;
    // doughnut clouds
    this.clouds = [];
    for (let i = 0; i < 9; i++) {
      const c = new THREE.Mesh(new THREE.TorusGeometry(rnd(2, 4), rnd(0.9, 1.6), 10, 20), new THREE.MeshToonMaterial({ color: 0xffffff }));
      c.rotation.x = Math.PI / 2 + rnd(-0.3, 0.3); c.position.set(rnd(-70, 70), rnd(8, 28), rnd(-80, 20)); c.userData.v = rnd(0.3, 0.9);
      s.add(c); this.clouds.push(c);
    }
  }

  // a fresh island: the same slab, a new random crowd
  generate() {
    for (const t of this.things) this.scene.remove(t.mesh);
    this.things = [];
    if (this.island) this.scene.remove(this.island);
    const g = new THREE.Group();
    const grass = pick([0x8fd36a, 0xa3e06e, 0x7ccf63, 0xb8e06b]);
    const slab = new THREE.Mesh(new THREE.BoxGeometry(this.w, 3, this.d), [toon(0x8b5a2b), toon(0x8b5a2b), toon(grass), toon(0x6b4423), toon(0x8b5a2b), toon(0x8b5a2b)]);
    slab.position.y = -1.5; slab.receiveShadow = true; g.add(slab);
    // patches of a second green, like the original's tiled ground
    for (let i = 0; i < 26; i++) {
      const p = new THREE.Mesh(new THREE.PlaneGeometry(rnd(2, 5), rnd(2, 5)), new THREE.MeshToonMaterial({ color: pick([0x9be07a, 0x7fc85d, 0xb5e88a]) }));
      p.rotation.x = -Math.PI / 2; p.position.set(rnd(-this.w / 2 + 3, this.w / 2 - 3), 0.01, rnd(-this.d / 2 + 3, this.d / 2 - 3)); p.receiveShadow = true; g.add(p);
    }
    this.scene.add(g); this.island = g;
    // BOY's house near the middle, facing the camera side
    const [homeMesh, hs, ho] = house(this, true); homeMesh.position.set(-2, 0, -6); this.home = new Thing(this, 'house', homeMesh, hs, ho); this.things.push(this.home);
    const door = this.homeDoor();
    const spot = (minR = 4) => { for (let k = 0; k < 40; k++) { const p = new THREE.Vector3(rnd(-this.w / 2 + 2.5, this.w / 2 - 2.5), 0, rnd(-this.d / 2 + 2.5, this.d / 2 - 2.5)); if (p.distanceTo(door) > 5 && this.things.every(t => t.mesh.position.distanceTo(p) > (t.fixed ? minR : 1.5))) return p; } return new THREE.Vector3(rnd(-15, 15), 0, rnd(-10, 10)); };
    const add = (kind, builder, count) => {
      for (let i = 0; i < count; i++) {
        const [mesh, size, opts] = builder(this);
        mesh.position.copy(spot(kind === 'house' ? 5 : 3));
        mesh.position.y = opts.baseY || 0; mesh.rotation.y = rnd(0, 6.28);
        const t = new Thing(this, kind, mesh, size, opts);
        if (opts.spin) t.spin = mesh.userData.spin;
        this.things.push(t);
      }
    };
    add('house', w => house(w), 2 + Math.floor(rnd(0, 3)));
    add('tree', tree, 4 + Math.floor(rnd(0, 5)));
    add('person', person, 5 + Math.floor(rnd(0, 6)));
    add('chicken', chicken, 2 + Math.floor(rnd(0, 4)));
    add('cow', cow, Math.floor(rnd(0, 3)));
    add('shark', shark, Math.random() < 0.7 ? 1 : 0);
    add('toucan', toucan, 1 + Math.floor(rnd(0, 2)));
    add('hovercar', hovercar, Math.random() < 0.7 ? 1 : 0);
    add('walker', walker, Math.random() < 0.5 ? 1 : 0);
    add('robot', robot, Math.floor(rnd(0, 3)));
    add('donut', donut, 1 + Math.floor(rnd(0, 3)));
    add('top', top, Math.floor(rnd(0, 3)));
    for (const t of this.things) if (t.flying) t.mesh.position.y = 4;
  }

  respawn(t) { t.airborne = false; t.vel.set(0, 0, 0); t.mesh.position.set(rnd(-12, 12), t.baseY, rnd(-8, 8)); }

  update(dt, t) {
    for (const th of this.things) if (!th.eaten) th.update(dt, t);
    for (const c of this.clouds) { c.position.x += c.userData.v * dt; if (c.position.x > 80) c.position.x = -80; }
    this.sun.rotateZ(dt * 0.02);
  }

  edibles() { return this.things.filter(t => !t.fixed); }
  homeDoor() { return this.home.mesh.position.clone().add(new THREE.Vector3(0, 0, 2.4)); }
}
