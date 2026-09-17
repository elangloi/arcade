// Little synthesised sounds and a gentle, endless tune — nothing is loaded from disk.
export class Audio {
  constructor() {
    this.ctx = null; this.muted = new URLSearchParams(location.search).has('mute');
    this.musicOn = true;
  }
  ensure() {
    if (this.muted) return null;
    if (!this.ctx) {
      this.ctx = new (window.AudioContext || window.webkitAudioContext)();
      this.master = this.ctx.createGain(); this.master.gain.value = 0.35; this.master.connect(this.ctx.destination);
      this.startMusic();
    }
    if (this.ctx.state === 'suspended') this.ctx.resume();
    return this.ctx;
  }
  tone({ freq = 440, to = null, type = 'sine', dur = 0.15, vol = 0.5, delay = 0 }) {
    const ctx = this.ensure(); if (!ctx) return;
    const t0 = ctx.currentTime + delay;
    const o = ctx.createOscillator(), g = ctx.createGain();
    o.type = type; o.frequency.setValueAtTime(freq, t0);
    if (to) o.frequency.exponentialRampToValueAtTime(to, t0 + dur);
    g.gain.setValueAtTime(0.0001, t0); g.gain.exponentialRampToValueAtTime(vol, t0 + 0.01); g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
    o.connect(g); g.connect(this.master); o.start(t0); o.stop(t0 + dur + 0.02);
  }
  // BOY gulps something down
  eat() { this.tone({ freq: 520, to: 180, type: 'triangle', dur: 0.25, vol: 0.5 }); this.tone({ freq: 90, to: 60, type: 'sine', dur: 0.3, vol: 0.4, delay: 0.08 }); }
  // something pops out the back
  pop() { this.tone({ freq: 200, to: 900, type: 'square', dur: 0.12, vol: 0.25 }); this.tone({ freq: 1200, to: 300, type: 'sine', dur: 0.18, vol: 0.3, delay: 0.05 }); }
  jump() { this.tone({ freq: 300, to: 700, type: 'triangle', dur: 0.18, vol: 0.3 }); }
  stretch() { this.tone({ freq: 240, to: 320, type: 'sine', dur: 0.08, vol: 0.12 }); }
  report() { [523, 659, 784, 1047].forEach((f, i) => this.tone({ freq: f, type: 'triangle', dur: 0.35, vol: 0.35, delay: i * 0.12 })); }
  fall() { this.tone({ freq: 600, to: 80, type: 'sine', dur: 0.9, vol: 0.35 }); }
  bump() { this.tone({ freq: 160, to: 120, type: 'triangle', dur: 0.08, vol: 0.2 }); }

  // a slow pentatonic lullaby that wanders forever, in the spirit of the original's easy-going music
  startMusic() {
    const ctx = this.ctx; const scale = [0, 2, 4, 7, 9, 12, 14, 16];
    const base = 261.63; let step = 0; let note = 3;
    const bus = ctx.createGain(); bus.gain.value = 0.5; bus.connect(this.master); this.musicBus = bus;
    const beat = 0.42;
    const play = (f, t, dur, type, vol) => {
      const o = ctx.createOscillator(), g = ctx.createGain(); o.type = type; o.frequency.value = f;
      g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(vol, t + 0.03); g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
      o.connect(g); g.connect(bus); o.start(t); o.stop(t + dur + 0.05);
    };
    let next = ctx.currentTime + 0.3;
    const tick = () => {
      if (!this.musicOn) { setTimeout(tick, 300); return; }
      while (next < ctx.currentTime + 1.2) {
        // melody: random walk on the pentatonic scale, mostly small steps
        note += [-2, -1, -1, 0, 1, 1, 2][Math.floor(Math.random() * 7)];
        note = Math.max(0, Math.min(scale.length - 1, note));
        if (step % 2 === 0 || Math.random() < 0.4) play(base * Math.pow(2, scale[note] / 12), next, beat * 1.6, 'triangle', 0.18);
        // a soft bass every four beats, chord tones every two
        if (step % 4 === 0) play(base / 2 * Math.pow(2, [0, 7, 9, 5][(step / 4) % 4] / 12), next, beat * 3.5, 'sine', 0.22);
        if (step % 2 === 1) play(base * Math.pow(2, [4, 7, 12, 9][Math.floor(step / 2) % 4] / 12), next, beat * 1.2, 'sine', 0.07);
        next += beat; step++;
      }
      setTimeout(tick, 250);
    };
    tick();
  }
  toggleMusic() { this.musicOn = !this.musicOn; if (this.musicBus) this.musicBus.gain.value = this.musicOn ? 0.5 : 0; return this.musicOn; }
}
