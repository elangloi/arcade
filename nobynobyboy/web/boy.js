// BOY: a stretchy rope of points with a pink head, a pink butt, a green middle and purple legs.
// Verlet integration + distance constraints; the head and butt are driven by the two "sticks".
import * as THREE from './vendor/three.module.js';

export const PINK = 0xff6fae, GREEN = 0x7ed957, PURPLE = 0x9b5de5, INK = 0x2a2440;
const BANDS = [0x7ed957, 0xffd23f, 0xff6fae, 0x5ec8ff, 0xff9f43, 0xc77dff];

const HEAD_R = 0.75, BODY_R = 0.42, LEG_R = 0.11;
const GRAVITY = -28, FLOAT_GRAVITY = -3;

export class Boy {
  constructor(scene, world) {
    this.scene = scene; this.world = world;
    this.group = new THREE.Group(); scene.add(this.group);
    // rope state
    this.n = 10;                    // points, head = 0, butt = n-1
    this.maxLength = 7;             // how far the ends can be apart (grows by eating)
    this.pts = []; this.prev = [];
    this.length = 0;                // current stretched length
    this.stretched = 0;             // metres stretched since the last report (positive deltas only)
    this.lastLength = 0;
    this.eaten = 0;
    this.stomach = [];              // {obj, t} things travelling down the body (t: 0 head .. 1 butt)
    this.colorShift = 0; this.bandPhase = 0; this.banded = false;
    this.floating = false;
    this.headDir = new THREE.Vector3(1, 0, 0);
    this.buildMeshes();
    this.reset(new THREE.Vector3(0, 0, 0));
  }

  reset(at) {
    this.pts = []; this.prev = [];
    for (let i = 0; i < this.n; i++) {
      const p = new THREE.Vector3(at.x + i * 0.3, at.y + HEAD_R, at.z);
      this.pts.push(p); this.prev.push(p.clone());
    }
    this.lastLength = this.currentLength();
  }

  get head() { return this.pts[0]; }
  get butt() { return this.pts[this.n - 1]; }
  mid() { return this.head.clone().add(this.butt).multiplyScalar(0.5); }

  currentLength() { let l = 0; for (let i = 1; i < this.n; i++) l += this.pts[i].distanceTo(this.pts[i - 1]); return l; }

  // ---- meshes
  buildMeshes() {
    const mat = c => new THREE.MeshToonMaterial({ color: c });
    const end = (color) => {
      const g = new THREE.Group();
      const s = new THREE.Mesh(new THREE.SphereGeometry(HEAD_R, 24, 18), mat(color)); s.castShadow = true; g.add(s);
      // four stubby purple legs
      g.legs = [];
      for (const [x, z] of [[-0.42, 0.42], [0.42, 0.42], [-0.42, -0.42], [0.42, -0.42]]) {
        const leg = new THREE.Mesh(new THREE.CylinderGeometry(LEG_R, LEG_R * 1.3, 0.55, 10), mat(PURPLE));
        leg.position.set(x, -0.55, z); leg.castShadow = true; g.add(leg); g.legs.push(leg);
      }
      return g;
    };
    this.headMesh = end(PINK); this.buttMesh = end(PINK);
    // the face: two eyes, a happy mouth
    const eyeM = new THREE.MeshBasicMaterial({ color: INK });
    for (const x of [-0.26, 0.26]) {
      const e = new THREE.Mesh(new THREE.SphereGeometry(0.1, 10, 8), eyeM); e.position.set(x, 0.2, HEAD_R - 0.06); this.headMesh.add(e);
      const gl = new THREE.Mesh(new THREE.SphereGeometry(0.035, 8, 6), new THREE.MeshBasicMaterial({ color: 0xffffff })); gl.position.set(x + 0.04, 0.24, HEAD_R + 0.03); this.headMesh.add(gl);
    }
    const mouth = new THREE.Mesh(new THREE.TorusGeometry(0.2, 0.035, 8, 20, Math.PI), eyeM);
    mouth.position.set(0, -0.1, HEAD_R - 0.02); mouth.rotation.z = Math.PI; this.headMesh.add(mouth);
    // the tail end gets a little tail
    const tail = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.5, 10), mat(PINK)); tail.position.set(0, 0.1, -HEAD_R - 0.15); tail.rotation.x = -Math.PI / 2; this.buttMesh.add(tail);
    this.group.add(this.headMesh, this.buttMesh);
    // body tube (rebuilt every frame)
    this.bodyMat = new THREE.MeshToonMaterial({ vertexColors: true });
    this.bodyMesh = new THREE.Mesh(new THREE.BufferGeometry(), this.bodyMat); this.bodyMesh.castShadow = true;
    this.group.add(this.bodyMesh);
    // lumps for eaten things
    this.lumpGeo = new THREE.SphereGeometry(1, 14, 10);
    this.lumps = [];
    // shadow blob
    this.shadow = new THREE.Mesh(new THREE.CircleGeometry(HEAD_R, 20), new THREE.MeshBasicMaterial({ color: 0x000000, transparent: true, opacity: 0.18 }));
    this.shadow.rotation.x = -Math.PI / 2; this.group.add(this.shadow);
    this.shadow2 = this.shadow.clone(); this.group.add(this.shadow2);
  }

  // ---- input each frame: headMove/buttMove are camera-relative unit vectors on the ground plane
  step(dt, input, camYaw) {
    const world = this.world;
    const speed = 11;
    const move = (stick) => {
      const f = new THREE.Vector3(-Math.sin(camYaw), 0, -Math.cos(camYaw)), r = new THREE.Vector3(f.z, 0, -f.x);
      return f.multiplyScalar(-stick.y).add(r.multiplyScalar(stick.x));
    };
    const hm = move(input.head), bm = move(input.butt);
    const g = (input.float ? FLOAT_GRAVITY : GRAVITY) * dt * dt;
    // verlet
    for (let i = 0; i < this.n; i++) {
      const p = this.pts[i], q = this.prev[i];
      const v = p.clone().sub(q).multiplyScalar(0.985);
      q.copy(p);
      p.add(v); p.y += g;
    }
    // sticks push the ends
    this.head.add(hm.clone().multiplyScalar(speed * dt * dt * 8));
    this.butt.add(bm.clone().multiplyScalar(speed * dt * dt * 8));
    if (hm.lengthSq() > 0.01) this.headDir.lerp(hm.clone().normalize(), 0.25);
    if (input.jump && this.grounded(0)) { this.prev[0].y = this.head.y - 0.42; input.jump = false; }
    if (input.jumpButt && this.grounded(this.n - 1)) { this.prev[this.n - 1].y = this.butt.y - 0.42; input.jumpButt = false; }
    // constraints: a rope whose segments may stretch up to their share of maxLength
    const segMax = this.maxLength / (this.n - 1), segMin = 0.35;
    for (let iter = 0; iter < 6; iter++) {
      for (let i = 1; i < this.n; i++) {
        const a = this.pts[i - 1], b = this.pts[i];
        const d = b.clone().sub(a); const len = d.length() || 1e-6;
        let target = null;
        if (len > segMax) target = segMax; else if (len < segMin) target = segMin;
        if (target !== null) {
          const corr = d.multiplyScalar((len - target) / len * 0.5);
          // the ends are heavier (the player is holding them)
          const wa = (i - 1 === 0) ? 0.3 : 1, wb = (i === this.n - 1) ? 0.3 : 1;
          const s = wa + wb;
          a.add(corr.clone().multiplyScalar(2 * wa / s)); b.sub(corr.clone().multiplyScalar(2 * wb / s));
        }
      }
      // ground / island
      for (let i = 0; i < this.n; i++) {
        const p = this.pts[i]; const r = (i === 0 || i === this.n - 1) ? HEAD_R : BODY_R;
        const gy = world.groundHeight(p.x, p.z);
        if (gy !== null && p.y < gy + r) { p.y = gy + r; this.prev[i].x += (p.x - this.prev[i].x) * 0.15; this.prev[i].z += (p.z - this.prev[i].z) * 0.15; }
        // solid things on the island
        world.pushOut(p, r);
      }
    }
    // stretch bookkeeping
    this.length = this.currentLength();
    if (this.length > this.lastLength + 1e-4) this.stretched += this.length - this.lastLength;
    this.lastLength = this.length;
    // digestion
    for (const l of this.stomach) if (l.t < 1) l.t = Math.min(1, l.t + dt / 3);
    if (this.banded) this.bandPhase += dt * 0.6;
    // fell off the world
    if (this.head.y < -25 || this.butt.y < -25) return 'fell';
    return null;
  }

  grounded(i) { const p = this.pts[i]; const gy = this.world.groundHeight(p.x, p.z); return gy !== null && p.y < gy + HEAD_R + 0.15; }

  // ---- eating / expelling
  tryEat(objs) {
    // the mouth is a little in front of the head
    const mouth = this.head.clone().add(this.headDir.clone().multiplyScalar(HEAD_R));
    let best = null, bd = 1e9;
    for (const o of objs) {
      if (o.eaten || o.fixed) continue;
      const d = o.position().distanceTo(mouth) - o.size;
      if (d < 1.6 && o.size <= this.biteSize() && d < bd) { best = o; bd = d; }
    }
    if (!best) return null;
    best.eat();
    this.stomach.push({ obj: best, t: 0 });
    this.eaten++;
    this.maxLength += 0.6 + best.size * 0.5;   // eating makes BOY stretchier
    this.n = Math.min(60, Math.round(this.maxLength * 1.6));
    while (this.pts.length < this.n) {   // grow the rope just behind the butt
      const k = this.pts.length - 1; const p = this.pts[k].clone().lerp(this.pts[k - 1], 0.5);
      this.pts.splice(k, 0, p); this.prev.splice(k, 0, p.clone());
    }
    return best;
  }
  biteSize() { return 0.7 + this.maxLength * 0.12; }
  expel() {
    const i = this.stomach.findIndex(l => l.t >= 1);
    if (i < 0) return null;
    const [l] = this.stomach.splice(i, 1);
    const back = this.butt.clone().sub(this.pts[this.n - 2]).normalize();
    l.obj.expel(this.butt.clone().add(back.multiplyScalar(HEAD_R + l.obj.size)), back.multiplyScalar(9).add(new THREE.Vector3(0, 7, 0)));
    return l.obj;
  }

  // ---- rendering
  render(t) {
    const curve = new THREE.CatmullRomCurve3(this.pts, false, 'catmullrom', 0.5);
    const segs = Math.max(24, this.n * 4);
    const geo = new THREE.TubeGeometry(curve, segs, BODY_R, 12, false);
    // colours per ring: green, or scrolling bands when the player has asked for them
    const pos = geo.attributes.position; const colors = new Float32Array(pos.count * 3); const col = new THREE.Color();
    const ringsPerSeg = 13;
    for (let i = 0; i < pos.count; i++) {
      const ring = Math.floor(i / ringsPerSeg);
      const u = ring / segs;
      if (this.banded) col.setHex(BANDS[Math.floor((u * 14 + this.bandPhase + this.colorShift) % BANDS.length + BANDS.length) % BANDS.length]);
      else col.setHex(GREEN);
      // lumps of food bulge the tube
      let bulge = 0;
      for (const l of this.stomach) { const d = Math.abs(l.t - u) * this.maxLength; bulge = Math.max(bulge, Math.max(0, 1 - d * 1.2) * l.obj.size * 0.8); }
      if (bulge > 0) { const v = new THREE.Vector3().fromBufferAttribute(pos, i); const c = curve.getPointAt(Math.min(1, u)); v.sub(c).multiplyScalar(1 + bulge / BODY_R).add(c); pos.setXYZ(i, v.x, v.y, v.z); }
      colors[i * 3] = col.r; colors[i * 3 + 1] = col.g; colors[i * 3 + 2] = col.b;
    }
    geo.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    geo.computeVertexNormals();
    this.bodyMesh.geometry.dispose(); this.bodyMesh.geometry = geo;
    // ends
    this.headMesh.position.copy(this.head);
    const look = this.head.clone().add(this.headDir); look.y = this.head.y; this.headMesh.lookAt(look);
    this.buttMesh.position.copy(this.butt);
    const bl = this.butt.clone().sub(this.pts[this.n - 2]); bl.y *= 0.3; this.buttMesh.lookAt(this.butt.clone().add(bl));
    // legs paddle while moving
    const wob = Math.sin(t * 14);
    const hv = this.head.clone().sub(this.prev[0]).length(), bv = this.butt.clone().sub(this.prev[this.n - 1]).length();
    this.headMesh.legs.forEach((l, i) => { l.rotation.x = wob * (i % 2 ? 1 : -1) * Math.min(1, hv * 8) * 0.6; });
    this.buttMesh.legs.forEach((l, i) => { l.rotation.x = wob * (i % 2 ? -1 : 1) * Math.min(1, bv * 8) * 0.6; });
    // shadows
    const sh = (m, p) => { const gy = this.world.groundHeight(p.x, p.z); m.visible = gy !== null; if (gy !== null) { m.position.set(p.x, gy + 0.02, p.z); const s = Math.max(0.3, 1 - (p.y - gy) * 0.08); m.scale.set(s, s, 1); } };
    sh(this.shadow, this.head); sh(this.shadow2, this.butt);
  }

  // where along the body a stomach item is (for sounds etc.)
  pointAt(u) { const c = new THREE.CatmullRomCurve3(this.pts, false, 'catmullrom', 0.5); return c.getPointAt(Math.min(1, Math.max(0, u))); }
}
