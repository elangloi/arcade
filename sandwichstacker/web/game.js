// 625 Sandwich Stacker — game logic ported from the SWF's ActionScript 2
// (see decompiled/code/*.txt). Sprite ids and frame labels are the original ones.
import { loadPlayer, MovieClip } from './player.js';

const random = n => Math.floor(Math.random() * n);
const DEBUG = new URLSearchParams(location.search).has('debug');
const dbg = (...a) => { if (DEBUG) console.log('[ss]', ...a); };

export async function boot(svgEl) {
  const P = await loadPlayer(svgEl);
  const main = P.root;
  main.score = 0;
  main.bonus = '';

  // ---- text field bindings (edit texts bound to _root.score, _parent.levelText, _parent._parent.bonus)
  const setTextVar = (_clip, name, value) => P.setVar(name, value);
  const showScore = () => setTextVar(main, 'score', String(main.score));

  // Reuben's anim clip, the game state object, the controller
  const V = () => main.v && main.v.vars;
  const barre = () => main.barre;

  // ---- main timeline ----------------------------------------------------------------
  P.onFrame('main', 1, () => { main.gotoAndStop('Play'); });            // preloader: nothing to load
  P.onFrame('main', 10, () => main.stop());                              // title
  P.onFrame('main', 20, () => main.stop());                              // how to play
  P.onFrame('main', 30, () => { main.score = 0; showScore(); });         // init (plays on to 'game')
  P.onFrame('main', 40, () => { main.stop(); showScore(); });            // game
  P.onFrame('main', 50, () => main.stop());                              // next level
  P.onFrame('main', 60, () => main.stop());                              // game over
  P.onFrame('main', 70, () => main.gotoAndStop('Play'));                 // score submission (Disney service) -> title

  // title buttons
  P.onButton(116, () => main.gotoAndPlay('init'));
  P.onButton(123, () => main.gotoAndStop('Instruction'));
  P.onButton(194, (btn) => {
    if (btn.parent.charId === 196) main.gotoAndPlay('init');            // title instructions -> play
    else instructionsGoToPlay();                                         // in-game help -> resume
  });
  P.onButton(438, () => { const v = V(); v.QuitWasPressed = v.HelpWasPressed = v.PauseWasPressed = false; main.gotoAndStop('game'); });
  P.onButton(465, () => main.gotoAndStop('Play'));                       // "submit score" -> title
  P.onButton(472, () => main.gotoAndPlay('init'));                       // play again

  // ---- v: game variables (sprite 381, placed at frame 39 so it survives level changes) --------
  P.onFrame(381, 1, (clip) => {
    if (clip.vars.init) return;
    const startRanBread = 9;
    clip.vars = {
      init: true, stageWidth: 580, speedDown: 7, intervalFall: 1100, PlateSpeed: 9, move: 0, pause: false,
      referenceFrame: 0, fallNumber: 100, sandwichHeight: 0, xMinFallObject: 36, xMaxFallObject: 370, minMaxDiff: 278,
      tempFood: 0, lifeScale: 3, nbrLife: 3, lifeChange: 3, bonusLife: 1000, gameOver: false, nbrSandLevel: 1, breadSlice: 17,
      levelNumber: 0, RandomBread: random(4) + startRanBread, endSandwich: false, sandwichCumul: 0, nbrSandwich: 0,
      ecranCumul: [2, 5, 9], startScore: 125, score: 0, moving: false, QuitWasPressed: false, HelpWasPressed: false,
      PauseWasPressed: false, lastXofFallObj: random(370 - 36) + 36, distBetweenFallObj: 270, bonus: 0, lastFallenElement: 0,
    };
  });

  // ---- HUD pieces --------------------------------------------------------------------------------
  // ickmeter (221): the "ick" bar grows as lives are lost
  // (it is placed at 'init' before v exists; the original's load handler then computes NaN, so the bar
  // starts empty and the real setup runs on the first frame v is around)
  const ickLoad = (clip, v) => {
    if (v.nbrLife > v.lifeChange) {
      const inverse = (v.lifeScale - v.nbrLife) + 1;
      clip.bar._xscale = Math.floor(inverse / v.lifeScale * 100);
      clip.gotoAndPlay('ding');
    } else {
      clip.bar._xscale = Math.floor((v.lifeScale - v.nbrLife) / v.lifeScale * 100);
    }
    v.lifeChange = v.nbrLife;
  };
  P.onFrame(221, 1, (clip) => {
    clip.stop();
    if (clip.vars.loaded) return;
    clip.vars.loaded = true;
    const v0 = V();
    if (v0) { clip.vars.init = true; ickLoad(clip, v0); } else clip.bar._xscale = 0;
    clip.onEnterFrame = function () {
      const v = V(); if (!v) return;
      if (!this.vars.init) { this.vars.init = true; ickLoad(this, v); return; }
      if (v.nbrLife !== v.lifeChange && v.nbrLife < v.lifeChange) {
        this.play();
        this.bar._xscale = Math.floor((v.lifeScale - v.nbrLife) / v.lifeScale * 100);
        this.bar.gotoAndPlay(1);
        v.lifeChange = v.nbrLife;
      }
    };
  });
  P.onFrame(221, 10, (clip) => clip.gotoAndStop(1));
  P.onFrame(221, 12, (clip) => { clip.bar.gotoAndPlay(2); clip.play(); });
  P.onFrame(221, 34, (clip) => {
    const v = V();
    clip.bar._xscale = Math.floor((v.lifeScale - v.nbrLife) / v.lifeScale * 100);
    clip.gotoAndStop(1);
  });
  P.onFrame(225, 1, c => c.stop());                 // sfx: 'silence' / 'munche' / 'stopMunche'
  P.onFrame(225, 21, c => c.gotoAndStop(1));
  P.onFrame(230, 1, c => c.stop());                 // toaster
  P.onFrame(230, 9, c => c.gotoAndStop('start'));
  P.onFrame(252, 1, c => c.stop());                 // quit popup
  P.onFrame(252, 10, c => { main.controler && hideFallObj(false); c.stop(); });
  P.onFrame(391, 1, c => c.stop());                 // "+bonus" flash
  P.onFrame(391, 19, c => c.gotoAndStop('inactive'));
  P.onFrame(424, 1, c => { if (!c.vars.picked) { c.vars.picked = true; c.gotoAndStop(random(5) + 1); } else c.stop(); });
  for (const f of [2, 3, 4, 5]) P.onFrame(424, f, c => c.stop());
  P.onFrame(45, 1, c => c.stop()); P.onFrame(45, 49, c => c.gotoAndStop(1));
  P.onFrame(290, 1, c => { c.stop(); if (random(3) === 0) c.play(); });
  P.onFrame(386, 35, c => c.stop());
  P.onFrame(315, 8, c => c.stop());
  P.onFrame(210, 1, c => c.stop());                 // HUD buttons bar
  P.onFrame(196, 1, c => c.stop());                 // title instructions
  P.onFrame(377, 1, c => c.stop());                 // in-game help
  P.onFrame(374, 1, c => c.stop());                 // falling object template
  P.onFrame(277, 1, c => {                            // food slots: the slot marker bar is hidden on load
    c.vars.Xoffset = 0; c.stop();
    for (const ch of c.children.values()) if (ch.charId === 255) ch._visible = false;
  });
  P.onFrame(277, 19, c => c.stop());

  // MClevel (386): "LEVEL n"
  P.onFrame(386, 1, (clip) => {
    const v = V(); if (!v) return;
    const onGameScreen = main.currentFrame < 50;
    setTextVar(clip, 'levelText', 'LEVEL ' + (onGameScreen ? v.levelNumber + 1 : v.levelNumber));
    if (!onGameScreen) clip.onEnterFrame = function () { if (this._currentframe > 15) this.stop(); };
  });

  // ---- pause / help / quit buttons (sprite 210 on the game screen) -------------------------------
  const pauseBarre = () => { const v = V(); v.pause = true; v.moving = false; barre().vars.action = 'pauseAction'; barre().gotoAndPlay('pauseAction'); };
  const resumeBarre = () => { const v = V(); v.pause = false; barre().vars.action = 'retourPause'; barre().gotoAndPlay('retourPause'); };
  P.onButton(201, (btn) => {   // pause
    const v = V();
    if (v.QuitWasPressed || v.HelpWasPressed || barre().vars.action === 'Swallow') return;
    if (v.PauseWasPressed === undefined) v.PauseWasPressed = false;
    if (v.pause === false) {
      pauseBarre(); v.PauseWasPressed = true;
      main.gotoAndStop('pause'); btn.parent.gotoAndStop(2);
    }
  });
  P.onButton(204, () => {      // help
    const v = V();
    if (!v.QuitWasPressed && !v.PauseWasPressed && barre().vars.action !== 'Swallow') {
      pauseBarre(); main.instructions.gotoAndStop(2); v.HelpWasPressed = true; hideFallObj(false);
    }
  });
  P.onButton(207, () => {      // quit
    const v = V();
    if (v.PauseWasPressed || v.HelpWasPressed || barre().vars.action === 'Swallow') return;
    if (!v.QuitWasPressed) { pauseBarre(); main.mcQuit.play(); v.QuitWasPressed = true; }
    else { v.QuitWasPressed = false; main.mcQuit.gotoAndStop(1); resumeBarre(); hideFallObj(true); }
  });
  P.onButton(209, (btn) => {   // resume (in the pause popup)
    const v = V();
    resumeBarre(); v.PauseWasPressed = false; main.gotoAndStop('game'); btn.parent.gotoAndStop(1);
  });
  P.onButton(250, () => {      // quit: yes
    const v = V(); v.endSandwich = false; v.sandwichHeight = 1; v.fallNumber = 100; v.RandomBread = random(4) + 9;
    main.gotoAndStop('Play');
  });
  P.onButton(251, (btn) => {   // quit: no
    const v = V(); v.QuitWasPressed = false; resumeBarre(); hideFallObj(true); btn.parent.gotoAndStop(1);
  });
  function instructionsGoToPlay() {
    const v = V(); v.HelpWasPressed = false; resumeBarre();
    if (!(v.nbrLife > 0)) setTimeout(() => { v.endSandwich = false; v.sandwichHeight = 1; v.fallNumber = 100; v.RandomBread = random(4) + 9; main.gotoAndStop('gameover'); }, 250);
    main.instructions.gotoAndStop(1); hideFallObj(true);
  }
  function hideFallObj(state) {
    const v = V(); if (!v) return;
    for (let i = v.fallNumber; main['mc' + i]; i--) main['mc' + i]._visible = state;
  }

  // ---- Reuben (barre, sprite 332) state machine --------------------------------------------------
  const barreStop = (c) => {
    const v = V();
    if (c.vars.action) c.gotoAndPlay(c.vars.action);
    else if (v && v.moving) c.gotoAndPlay('marche');
    else c.play();
  };
  P.onFrame(332, 1, (c) => { if (c.vars.action === undefined) c.vars.action = ''; barreStop(c); });
  for (let f = 2; f <= 9; f++) P.onFrame(332, f, barreStop);
  P.onFrame(332, 10, (c) => { barreStop(c); if (c.currentFrame === 10) c.gotoAndPlay('Stop'); });
  P.onFrame(332, 11, (c) => { if (c.vars.action) c.gotoAndPlay(c.vars.action); else c.play(); });
  P.onFrame(332, 15, (c) => {
    const v = V();
    if (c.vars.action) c.gotoAndPlay(c.vars.action);
    else if (v.moving) c.gotoAndPlay('marche');
    else c.gotoAndPlay('Stop');
  });
  P.onFrame(332, 16, (c) => { c.onEnterFrame = function () { if (V().moving) { this.gotoAndPlay('retourPause'); this.onEnterFrame = null; } }; });
  P.onFrame(332, 125, (c) => c.gotoAndPlay('pauseLoop'));
  P.onFrame(332, 126, (c) => c.play());
  const scheduleGameOver = () => setTimeout(() => {
    const v = V(); if (!v) return;
    v.endSandwich = false; v.sandwichHeight = 1; v.fallNumber = 100; v.RandomBread = random(4) + 9;
    main.gotoAndStop('gameover');
  }, 250);
  P.onFrame(332, 128, (c) => { if (V().nbrLife === 0) scheduleGameOver(); c.vars.action = ''; c.gotoAndPlay('Stop'); });
  P.onFrame(332, 129, (c) => c.play());
  P.onFrame(332, 138, (c) => { if (c.vars.condType !== 'bad') { c.vars.action = ''; c.gotoAndPlay('Stop'); } else c.vars.condType = 'good'; });
  P.onFrame(332, 139, (c) => c.play());
  P.onFrame(332, 150, (c) => { if (!(V().nbrLife > 0)) scheduleGameOver(); c.vars.action = ''; c.gotoAndPlay('Stop'); });
  P.onFrame(332, 151, (c) => c.play());
  P.onFrame(332, 161, (c) => { const v = V(); if (v.nbrSandwich === v.nbrSandLevel) main.gotoAndStop('nextlevel'); c.vars.action = ''; c.gotoAndPlay('Stop'); });

  // ---- the controller (sprite 394): spawning, plate movement, game over ----------------------------
  function FiniSandwiche() {
    const v = V();
    v.sandwichCumul++; v.nbrSandwich++;
    const top = main['food' + (v.sandwichHeight - 1)]; if (top) top.play();   // (food0 -> no-op in AS2)
    v.endSandwich = false; v.fallNumber = 100; v.RandomBread = random(4) + 9;
    barre().gotoAndPlay('Swallow'); barre().vars.action = 'Swallow';
    if (!(v.score < v.bonusLife)) {
      if (v.lifeScale > v.nbrLife) { v.nbrLife++; main.Life = v.nbrLife; }
      v.bonusLife += 1000;
    }
  }
  P.onFrame(394, 1, (ctl) => {
    const v = V();
    v.referenceFrame = main.currentFrame;
    v.endSandwich = false; v.sandwichHeight = 1; v.fallNumber = 100; v.RandomBread = random(4) + 9;
    main.Life = v.nbrLife; main.score = v.score; showScore();
    ctl.vars.intervFallObj = P.getTimer() + v.intervalFall;
    ctl.vars.pauseWasPressed = false;
    v.pause = false;
    ctl.vars.FiniSandwiche = FiniSandwiche;
    ctl.onEnterFrame = function () {
      const v = V(); const s = this.vars;
      if (v.pause) {
        if (s.pauseWasPressed === false) s.intervalLeft = s.intervFallObj - P.getTimer();
        s.pauseWasPressed = true;
        return;
      }
      if (s.pauseWasPressed) { s.intervFallObj = P.getTimer() + s.intervalLeft; s.pauseWasPressed = false; }
      if (s.intervFallObj < P.getTimer()) {
        s.intervFallObj += v.intervalFall;
        let Xrandom;
        do {
          Xrandom = random(2) ? v.lastXofFallObj - random(v.distBetweenFallObj) : v.lastXofFallObj + random(v.distBetweenFallObj);
        } while (Xrandom > v.xMaxFallObject || Xrandom < v.xMinFallObject);
        v.fallNumber++;
        const mc = main.fallingObject.duplicateMovieClip('mc' + v.fallNumber, 16384 + v.fallNumber);
        mc._x = Xrandom;
        startFall(mc);
        v.lastXofFallObj = Xrandom;
      }
      v.moving = false;
      const L = P.isKeyDown(37), R = P.isKeyDown(39);
      if (L && !R) {
        if (barre()._x > v.xMinFallObject) { v.move = -v.PlateSpeed; barre()._x -= v.PlateSpeed; v.moving = true; }
      } else if (R && !L) {
        if (barre()._x < v.xMaxFallObject) { v.move = v.PlateSpeed; barre()._x += v.PlateSpeed; v.moving = true; }
      }
      const top = main.food28;
      if (top && top._currentframe !== 1 && top._currentframe !== v.breadSlice) { v.gameOver = true; main.gotoAndPlay('gameover'); }
    };
  });

  // ---- falling objects (sprite 374) --------------------------------------------------------------
  function startFall(mc) {
    mc.scriptMoved = true;
    mc.gotoAndStop('fall');
  }
  P.onFrame(374, 10, (mc) => {
    mc.stop();
    const v = V();
    // pick what falls (the original did this in the child clip's load handler)
    let RandomElement;
    if (!((v.fallNumber - 100) < v.RandomBread) && v.sandwichHeight > 3) {
      RandomElement = v.breadSlice;
      v.RandomBread += v.RandomBread;
      main.toaster.play();
      mc._y = -30 * v.speedDown;
      main.controler.vars.intervFallObj += 1500;
    } else {
      do { RandomElement = random(16) + 1; } while (RandomElement === 1 || v.lastFallenElement === RandomElement);
      if (RandomElement < 12) v.lastFallenElement = RandomElement;
    }
    dbg('pick', mc._name, mc.uid, RandomElement, 'prev', mc.vars.RandomElement, 'y', Math.round(mc._y), 'created', mc.justCreated);
    mc.vars.RandomElement = RandomElement;
    if (mc.completeObjects) mc.completeObjects.gotoAndStop(RandomElement);
    if (main.fallObjOrient === undefined) main.fallObjOrient = -1;
    main.fallObjOrient *= -1;
    mc._xscale = 100 * main.fallObjOrient;
    mc.onEnterFrame = function () {
      const v = V(); const r1 = main;
      if (!v) { this.removeMovieClip(); return; }   // left the game screen (quit to title)
      const yark = () => {
        dbg('yark', this._name, this.uid, el, Math.round(this._x), Math.round(this._y), 'h', v.sandwichHeight, 'life', v.nbrLife - 1);
        barre().gotoAndPlay('YARK'); barre().vars.action = 'YARK';
        v.nbrLife--; r1.Life = v.nbrLife;
        this.play(); this.onEnterFrame = null;
      };
      if ((v.referenceFrame - r1.currentFrame) < -9) { this.removeMovieClip(); return; }
      if (v.pause === true) return;
      if (this._y < 410) this._y += v.speedDown; else { this.removeMovieClip(); return; }
      if (v.gameOver === true || v.endSandwich === true) { this.removeMovieClip(); return; }
      const el = this.vars.RandomElement;
      if (v.sandwichHeight === 1) {
        const b = barre();
        if (this._y > b._y - 3 && this._y < b._y + v.speedDown * 2 && this._x > b._x - 30 && this._x < b._x + 30) {
          if (!(el > 11)) {
            dbg('catch', this._name, this.uid, el, Math.round(this._x), Math.round(this._y), 'h', v.sandwichHeight);
            v.tempFood = el;
            const f = r1['food' + v.sandwichHeight];
            f.vars.Xoffset = this._x; f.gotoAndPlay('follow');
            v.sandwichHeight++;
            this.removeMovieClip();
          } else yark();
        }
      } else {
        const r3 = r1['food' + (v.sandwichHeight - 1)];
        const fixe = r3 && r3.objectFixe;
        if (fixe && this._y > r3._y - 3 && this._y < r3._y + v.speedDown * 2 && this._x > fixe._x + 125 && this._x < fixe._x + 225) {
          if (!(el > 11)) {
            dbg('catch', this._name, this.uid, el, Math.round(this._x), Math.round(this._y), 'h', v.sandwichHeight);
            v.tempFood = el; r1['food' + v.sandwichHeight].gotoAndPlay('follow'); v.sandwichHeight++;
            this.removeMovieClip();
          } else if (el === v.breadSlice) {
            v.tempFood = el; r1['food' + v.sandwichHeight].gotoAndPlay('bread'); v.sandwichHeight++;
            v.endSandwich = true; r1.sfx.gotoAndStop('munche'); v.bonus = 0;
            this.removeMovieClip();
          } else yark();
        }
      }
    };
  });
  P.onFrame(374, 12, (mc) => {   // the "caught" art frames use a differently ordered library (316)
    for (const c of mc.children.values()) if (c.charId === 316) { c.gotoAndStop(mc.vars.RandomElement - 1); c._xscale = 100 * main.fallObjOrient; }
  });
  P.onFrame(374, 19, (mc) => mc.removeMovieClip());
  // some ingredient art is flipped upside down at random when it appears (completeObjects children)
  for (const id of [342, 346, 347, 350, 351, 352, 364, 136]) P.onLoad(id, (c) => { if (random(2)) c._yscale = -100; });

  // ---- stacked food pieces (sprite 277 -> child objectFixe sprite 276) ---------------------------
  P.onFrame(277, 10, (food) => food.play());
  // objectFixe (276) is placed at 'follow' (frame 10) and lives through 'bread' (20-29); its load handler
  // carries the stacking/sway logic, so it must run for either entry point
  P.onLoad(276, (fixe) => {
    const food = fixe._parent; if (!food || food.charId !== 277) return;
    const v = V(); if (!v) return;
    const positionNum = Number(food._name.slice(4));
    fixe.scriptMoved = true;
    if (v.tempFood !== 0) {
      fixe._x = barre()._x - 175;
      fixe.gotoAndStop(v.tempFood);
      v.tempFood = 0;
    }
    if (main.folowObjOrient === undefined) main.folowObjOrient = -1;
    main.folowObjOrient *= -1;
    fixe._xscale = 100 * main.folowObjOrient;
    const below = main['food' + (positionNum - 1)];
    if (below && below.objectFixe) fixe._x = below.objectFixe._x;
    fixe.vars.decompte = function () {
      let waitAframe;
      fixe.onEnterFrame = function () {
        const v = V();
        if (waitAframe === undefined) { waitAframe = 'defined'; return; }
        v.score += 5 * positionNum; main.score = v.score; showScore();
        v.bonus += 5 * positionNum; main.bonus = '+' + v.bonus; setTextVar(main.MCbonus, 'bonus', main.bonus);
        main.MCbonus.play();
        const lower = main['food' + (positionNum - 1)];
        if (lower && lower.objectFixe && lower.objectFixe.vars.decompte) lower.objectFixe.vars.decompte();
        else {
          v.sandwichHeight = 1;
          if (v.endSandwich === true) FiniSandwiche();
          main.sfx.gotoAndStop('stopMunche');
        }
        food.gotoAndStop('inactive');
      };
    };
    fixe.onEnterFrame = function () {
      const v = V(); if (v.pause) return;
      let r2 = v.sandwichHeight / 2;
      r2 = r2 - Math.abs(r2 - positionNum);
      r2 *= 2;
      const plateauX = barre()._x - 175;
      if (positionNum === 1) { this._x = plateauX; return; }
      this._x += (2 * positionNum / 100) * v.move;
      if (this._x > plateauX + (2 * positionNum + r2)) {
        this._x = plateauX + (2 * positionNum + r2);
        if (!v.moving) v.move *= -0.7;
      } else if (this._x < plateauX - (2 * positionNum + r2)) {
        this._x = plateauX - (2 * positionNum + r2);
        if (!v.moving) v.move *= -0.7;
      }
      const lowerFixe = main['food' + (positionNum - 1)] && main['food' + (positionNum - 1)].objectFixe;
      this._rotation = lowerFixe ? this._x - lowerFixe._x : 0;
    };
  });
  P.onFrame(277, 29, (food) => { food.stop(); if (food.objectFixe && food.objectFixe.vars.decompte) food.objectFixe.vars.decompte(); });

  // ---- next level screen (sprite 443 carries the level-up logic) ---------------------------------
  P.onFrame(443, 1, (clip) => {
    const v = V(); if (!v || clip.vars.done) return;
    clip.vars.done = true;
    v.speedDown += v.speedDown * 0.01;
    v.intervalFall -= v.intervalFall * 0.04; if (v.intervalFall < 700) v.intervalFall = 700;
    v.distBetweenFallObj -= v.distBetweenFallObj * 0.01;
    v.PlateSpeed += v.PlateSpeed * 0.01;
    v.nbrSandwich = 0;
    v.levelNumber++;
    v.sandwichHeight = 1; v.fallNumber = 100; v.RandomBread = random(4) + 9;
    setTextVar(main, 'levelText', 'LEVEL ' + v.levelNumber);
    clip.onEnterFrame = () => { if (P.isKeyDown(32) || P.isKeyDown(13)) main.gotoAndStop('game'); };
  });

  // ingredient sub-animations (t1/t2/t3 clips) freeze while paused
  P.onTick = () => {
    const v = V();
    if (!v) return;
    const walk = (clip) => {
      for (const c of clip.children.values()) if (c instanceof MovieClip) {
        if (/^t[123]$/.test(c._name)) c.playing = !v.pause;
        walk(c);
      }
    };
    walk(main);
  };

  P.start();
  return P;
}
