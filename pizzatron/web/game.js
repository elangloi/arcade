// Pizzatron 3000 — game logic ported from the SWF's ActionScript 2 (see decompiled/code/*.txt).
// Sprite ids, instance names and frame labels are the original ones. The Club Penguin shell
// (coins, stamps, the "Disney Learning" reporting) is stubbed: the game runs on its own.
import { loadPlayer, MovieClip } from '../../flash/web/player.js';
import { STOPS, ORDERS } from './tables.js';

const random = n => Math.floor(Math.random() * n);
const DEBUG = new URLSearchParams(location.search).has('debug');
const dbg = (...a) => { if (DEBUG) console.log('[pz]', ...a); };
const LANG = 'lang/en/';

// a few Club Penguin penguin colours for the title screen (the shell would supply the player's own)
const PENGUIN_COLOURS = [0x003399, 0x009900, 0x006600, 0x8bd402, 0x663300, 0xfc9c38, 0xff6600, 0x333333, 0xcc0000, 0xff66cc, 0xffcc00, 0x660066, 0x33cccc];

export async function boot(svgEl) {
  const P = await loadPlayer(svgEl, '../assets/');
  const main = P.root;
  // belt speed multiplier (1 = the original; the page offers slower settings for trackpad players)
  P.speedScale = Number(new URLSearchParams(location.search).get('speed')) || 1;
  const locale = (await P.loadMovie('../assets/' + LANG + 'locale/')).json.locale;
  const T = key => locale[key] !== undefined ? locale[key] : key;
  const orders = ORDERS(T);

  // sprites whose frame scripts are just stop()
  for (const [sid, frames] of Object.entries(STOPS)) for (const f of frames) P.onFrame(Number(sid), f, c => c.stop());

  // ---- game state (the original kept all of this as variables on the main timeline) ----------
  const g = { candyMODE: false };
  let bgMusic = null;
  const startMusic = () => {
    if (bgMusic) return;
    bgMusic = P.sound('backgroundLoop'); bgMusic.setVolume(45); bgMusic.start(0, 99);
  };
  // (browsers only allow audio after a user gesture)
  window.addEventListener('mousedown', startMusic, { once: true });
  window.addEventListener('keydown', startMusic, { once: true });

  const showVars = () => { P.setVar('failures', g.failures); P.setVar('pizzasleft', g.pizzasleft); P.setVar('pizzasmade', g.pizzasmade); P.setVar('coins', g.coins); };

  // ---- main timeline ----------------------------------------------------------------
  P.onFrame('main', 1, () => { main.gotoAndStop('title'); });
  P.onFrame('main', 2, () => {
    main.stop();
    const title = main.title_mc;
    title.titlescreen_mc.titleImage.loadClip('../assets/' + LANG + 'title/');
    title.ui_play.text = T('ui_play');
    title.ui_instructions.text = T('title_instructions');
    title.titlescreen_mc.switch_mc.switch_handle.setHandler('onRelease', () => {
      g.candyMODE = !g.candyMODE;
      title.titlescreen_mc.switch_mc.gotoAndStop(g.candyMODE ? 2 : 1);
    });
    title.titlescreen_mc.penguin_mc.setRGB(PENGUIN_COLOURS[random(PENGUIN_COLOURS.length)]);
    g.candyMODE = false;
    svgEl.classList.remove('playing');
  });
  P.onFrame(585, 2, (title) => {   // instructions page of the title clip
    const i = title.instructions;
    i.orders_title.text = T('orders_title'); i.sauces_title.text = T('sauces_title'); i.toppings_title.text = T('toppings_title');
    i.orders_title_shadow.text = T('orders_title'); i.sauces_title_shadow.text = T('sauces_title'); i.toppings_title_shadow.text = T('toppings_title');
    i.help_make.text = T('help_make'); i.sauces_txt.text = T('help_sauce'); i.toppings_txt.text = T('help_drag');
    const cp = i.cheese_pizza && i.cheese_pizza.cheese_pizza_mc;
    if (cp) {
      cp.pizza_txt.text = T('pizza_shrimp'); cp.topping1_txt.text = T('topping_cheese');
      cp.topping2_txt.text = T('topping_pizzasauce'); cp.topping3_txt.text = '5 ' + T('topping_shrimps');
    }
    i.ui_play.text = T('ui_play');
  });
  P.onButton(525, () => main.gotoAndStop('rush'));                        // PLAY
  P.onButton(526, (b) => b.parent.gotoAndStop('intructions'));            // INSTRUCTIONS (sic)
  P.onButton(579, () => main.gotoAndStop('rush'));                        // PLAY (from the instructions)
  P.onButton(533, () => main.gotoAndStop('title'));                       // quit (the shell would close the game)
  for (const id of [652, 667, 670]) P.onButton(id, () => main.gotoAndStop('title'));   // DONE on the results screens

  // the sauce bottles and the title logo are separate SWFs loaded into placeholder clips
  P.onLoad(250, c => c.saucebottle && c.saucebottle.loadClip('../assets/' + LANG + 'hotsauce/'));
  P.onLoad(262, c => c.saucebottle && c.saucebottle.loadClip('../assets/' + LANG + 'hotsauce_squeeze/'));
  P.onLoad(521, c => c.saucebottle && c.saucebottle.loadClip('../assets/' + LANG + 'hotsauce_squeeze/'));
  P.onLoad(264, c => c.chocolatebottle && c.chocolatebottle.loadClip('../assets/' + LANG + 'sauce/'));
  P.onLoad(267, c => c.chocolatebottle && c.chocolatebottle.loadClip('../assets/' + LANG + 'sauce_squeeze/'));
  P.onFrame(592, 5, (c) => { c.stop(); if (g.mySound) g.mySound.stop(); if (c.chocolatebottle) c.chocolatebottle.loadClip('../assets/' + LANG + 'sauce/'); });

  // ---- the order screen (sprite 490): each frame is one order ---------------------------------
  for (const o of orders) {
    P.onFrame(490, o.frame, (screen) => {
      screen.stop();
      for (const [name, text] of Object.entries(o.texts)) if (screen[name]) screen[name].text = text;
      Object.assign(g, o.req);
    });
  }

  // ---- HUD pieces -----------------------------------------------------------------------
  P.onFrame(597, 2, c => { c.stop(); if (c.sprinkles_label) c.sprinkles_label.text = T('topping_sprinkles'); });
  P.onFrame(618, 1, c => { c.stop(); c.coin_label.text = '+5 ' + T('score_coins') + '!'; });
  P.onFrame(618, 2, c => { c.stop(); c.coin_label.text = '+10 ' + T('score_coins') + '!'; });
  const tipClips = { 622: null, 625: 10, 628: 15, 631: 20, 634: 25, 637: 30, 640: 35 };
  for (const [sid, tip] of Object.entries(tipClips)) {
    P.onFrame(Number(sid), 1, c => { c.done_label.text = T('score_done'); if (tip && c.tip_label) c.tip_label.text = `+${tip} ${T('score_tip')}`; });
    P.onFrame(Number(sid), 17, c => c.parent.gotoAndStop('none'));
  }
  for (let f = 2; f <= 8; f++) P.onFrame(641, f, c => { c.stop(); if (g.chachingSound) g.chachingSound.start(0, 1); });

  // the hand (sprite 272): sauce bottles squirt while in use
  const handSound = (c, name) => { if (g.mySound) g.mySound.stop(); g.mySound = P.sound(name); g.mySound.setVolume(100); g.mySound.start(0, 99); };
  for (const f of [1, 2, 4, 12, 14]) P.onFrame(272, f, c => { c.stop(); if (g.mySound) g.mySound.stop(); });
  P.onFrame(272, 3, c => { c.stop(); handSound(c, 'squirt'); });
  P.onFrame(272, 5, c => { c.stop(); handSound(c, '2'); });
  P.onFrame(272, 13, c => { c.stop(); handSound(c, 'squirt'); });
  P.onFrame(272, 15, c => { c.stop(); handSound(c, 'squirt'); });

  // dropped toppings fall off the bottom and remove themselves
  const dropIds = [276, 281, 285, 286, 287, 291, 295, 299, 300, 304, 305, 309, 310];
  for (const id of dropIds) P.onLoad(id, c => { c.onEnterFrame = function () { if (this._y >= 600) this.removeMovieClip(); }; });

  // the conveyor belt (sprite 494): ten segments scroll with the pizza speed
  P.onLoad(494, (belt) => {
    belt.onEnterFrame = function () {
      if (!(this.parent === main && g.gameplay)) return;   // (the copy on the instructions page stays still)
      for (let i = 0; i < 10; i++) {
        const mc = this['conv' + i]; if (!mc) continue;
        if (mc._x > 500) mc._x -= 1000;
        mc._x += (g.pizzaspeed + g.speedboost) * P.speedScale;
      }
    };
  });

  // ---- the game (main frame 3, 'rush') ------------------------------------------------------
  const mouse = () => P.mouse;   // stage coordinates (_root._xmouse/_ymouse)

  function makeorder() {
    const os = main.orderscreen;
    g.orderScreenFrame = os._currentframe;
    g.possibleorders = g.candyMODE ? 24 : Math.round(g.pizzasmade);
    if (g.possibleorders > g.maxpossibleorders) g.possibleorders = g.maxpossibleorders;
    if (g.perfectpizza === true) { g.order = random(g.possibleorders) + 1; g.perfectpizza = false; }
    os.gotoAndStop(g.candyMODE ? g.order + 24 : g.order);
    g.gameMODE = 'loadpizzas';
  }
  function loadpizzas() {
    const pizza = main.pizza;
    const t = (n) => {
      if (g[`topping${n}REQUESTED`] === true) g[`perfecttopping${n}`] = !(g[`topping${n}`] < g[`Ntopping${n}REQUESTED`]);
      else if (g[`topping${n}`] === 0) g[`perfecttopping${n}`] = true;
      else { g[`perfecttopping${n}`] = false; g.speedboost += 1; }
    };
    t(1); t(2); t(3); t(4);
    if (g.normalsaucePLACED === g.normalsauceREQUESTED && g.hotsaucePLACED === g.hotsauceREQUESTED && g.cheesePLACED === g.cheeseREQUESTED &&
        g.perfecttopping1 && g.perfecttopping2 && g.perfecttopping3 && g.perfecttopping4) { g.perfectpizza = true; g.speedboost += 1; }
    else g.perfectpizza = false;
    const covered = (layer) => ['toppart', 'bottompart', 'leftpart', 'midrightpart', 'midleftpart', 'rightpart']
      .every(part => layer.hitTest(pizza[part]._x + pizza._x, pizza[part]._y + pizza._y, true));
    g.normalsaucePLACED = covered(pizza.sauce);
    g.hotsaucePLACED = covered(pizza.hotsauce);
    if (pizza._x < 900) pizza._x += (g.pizzaspeed + g.speedboost) * P.speedScale;
    else g.gameMODE = 'removepizza';
  }
  function removepizza() {
    if (g.perfectpizza === true) {
      g.consecutivePizzas++;
      g.handicap += 1;
      main.txt_popup.gotoAndStop('perfect');
      if (g.candyMODE) main.txt_popup.earned.gotoAndStop('tip10');
      g.pizzasmade += 1;
      g.score += 5;
      if (g.candyMODE) g.score += 5;
    } else {
      g.consecutivePizzas = 0;
      g.handicap -= 1;
      g.failures += 1;
    }
    g.ordersmade += 1;
    g.pizzasleft -= 1;
    for (let i = 30; i > 0; i--) g['perfectpizzas' + i] = g['perfectpizzas' + (i - 1)];
    g.perfectpizzas1 = g.perfectpizza === true;
    const streak = n => { for (let i = 1; i <= n; i++) if (g['perfectpizzas' + i] !== true) return false; return true; };
    if (streak(30)) { main.txt_popup.gotoAndStop('combo35'); g.tips += 35; }
    else if (streak(25)) { main.txt_popup.gotoAndStop('combo30'); g.tips += 30; }
    else if (streak(20)) { main.txt_popup.gotoAndStop('combo25'); g.tips += 25; }
    else if (streak(15)) { main.txt_popup.gotoAndStop('combo20'); g.tips += 20; }
    else if (streak(10)) { main.txt_popup.gotoAndStop('combo15'); g.tips += 15; }
    else if (streak(5)) { main.txt_popup.gotoAndStop('combo10'); g.tips += 10; }
    dbg('pizza done', g.perfectpizza ? 'PERFECT' : 'wrong', 'order', g.order, 'made', g.pizzasmade, 'failures', g.failures, 'score', g.score, 'tips', g.tips,
      g.perfectpizza ? '' : `sauce ${g.normalsaucePLACED}/${g.normalsauceREQUESTED} hot ${g.hotsaucePLACED}/${g.hotsauceREQUESTED} cheese ${g.cheesePLACED}/${g.cheeseREQUESTED} t ${[1, 2, 3, 4].map(n => g['topping' + n] + '/' + (g[`topping${n}REQUESTED`] ? g[`Ntopping${n}REQUESTED`] : 0)).join(' ')}`);
    if (main.pizza) main.pizza.removeMovieClip();
    g.normalsaucePLACED = false; g.hotsaucePLACED = false; g.cheesePLACED = false;
    g.topping1 = 0; g.topping2 = 0; g.topping3 = 0; g.topping4 = 0;
    g.perfecttopping1 = false; g.perfecttopping2 = false; g.perfecttopping3 = false; g.perfecttopping4 = false;
    g.splatN = -300;
    g.speedboost = 0;
    g.gameMODE = 'placepizza';
    showVars();
  }
  function placepizza() {
    const pizza = main.attachMovie('pizza', 'pizza', 1);
    pizza._x = -240;
    pizza._y = 375;
    g.gameMODE = 'makeorder';
  }
  const modes = { makeorder, loadpizzas, removepizza, placepizza, gameover() { } };

  // throwing an ingredient away: it tumbles off with the mouse's momentum
  function dropTopping(linkage, rotate, frame) {
    const d = main.attachMovie(linkage, 'droppedtopping' + g.dropN, g.dropN);
    const m = mouse();
    d._x = m.x; d._y = m.y;
    if (frame) d.gotoAndStop(frame);
    g['droprotate' + g.dropN] = rotate;
    g['dropspeedX' + g.dropN] -= g.strengthX;
    g['dropspeedY' + g.dropN] -= g.strengthY;
    g.dropN += 1;
    if (g.dropN > 1010) g.dropN = 1001;
    if (!(g.strengthX < 30) || !(g.strengthX > -30)) g.zipSound.start(0, 1);
  }
  function sauceIngredient(kind) {   // kind: 'normalsauce' | 'hotsauce'
    const hot = kind === 'hotsauce';
    const pizza = main.pizza, hand = main.hand, m = mouse();
    main.ingredients_sauces.gotoAndStop(g.candyMODE ? (hot ? 'usingpinkicing' : 'usingchocolatesauce') : (hot ? 'usinghotsauce' : 'usingnormalsauce'));
    const handFrame = g.candyMODE ? (hot ? 'pinkicing' : 'chocolatesauce') : (hot ? 'hotsauce' : 'normalsauce');
    if (g.mouseisdown === false) hand.gotoAndStop(handFrame);
    else if (g.mouseisdown === true && g.splatN < -10) hand.gotoAndStop(handFrame + '_use');
    const layer = hot ? pizza.hotsauce : pizza.sauce, other = hot ? pizza.sauce : pizza.hotsauce;
    if (pizza.hitTest(m.x, m.y + 100, true) && g.mouseisdown === true && g.splatN < -10) {
      if ((hot ? g.hotsaucePLACED : g.normalsaucePLACED) === false) {
        const splat = layer.attachMovie(g.candyMODE ? (hot ? 'splat_pinkicing' : 'splat_chocolatesauce') : (hot ? 'splat_hotsauce' : 'splat_normalsauce'), 'splat' + g.splatN, g.splatN);
        splat._x = m.x - pizza._x;
        splat._y = m.y - pizza._y + 100;
        splat.gotoAndStop(random(4) + 1);
        for (let i = -300; i < -1; i++) if (other['splat' + i]) other['splat' + i].gotoAndStop('gone');
      }
      g.splatN += 1;
      if (g.splatN > -2) g.splatN = -300;
    } else if (g.mouseisdown === false) {
      g.ingredient = 'none';
      hand.gotoAndStop('none');
      g[hot ? 'sauce1Thrown' : 'sauce0Thrown'] = true;
      checkForMessOfKitchen();
      dropTopping(g.candyMODE ? (hot ? 'droppinkicing' : 'dropchocolatesauce') : (hot ? 'drophotsauce' : 'dropsauce'), true);
    }
  }
  const ingredients = {
    none() {
      main.ingredients_sauces.gotoAndStop(g.candyMODE ? 'normalcandy' : 'normal');
      main.hand.gotoAndStop('none');
    },
    normalsauce() { sauceIngredient('normalsauce'); },
    hotsauce() { sauceIngredient('hotsauce'); },
    cheese() {
      const pizza = main.pizza, hand = main.hand, m = mouse();
      hand.gotoAndStop(g.candyMODE ? 'sprinkles' : 'cheese');
      if (pizza.hitTest(m.x, m.y, true) && g.mouseisdown === false) {
        pizza.cheese.gotoAndStop(g.candyMODE ? 'placedcandy' : 'placed');
        g.cheesePLACED = true;
        g.ingredient = 'none';
        g.toppingSound.start(0, 1);
      } else if (g.mouseisdown === false) {
        g.ingredient = 'none';
        hand.gotoAndStop('none');
        g.topping0Thrown = true;
        checkForMessOfKitchen();
        dropTopping(g.candyMODE ? 'dropsprinkles' : 'dropcheese', false);
      }
    },
  };
  const dropFor = { 1: ['dropseaweed', 'dropliquorice'], 2: ['dropshrimp', 'dropchocolatechip'], 3: ['dropsquid', 'dropmarshmellow'], 4: ['dropfish', 'dropjellybean'] };
  for (let n = 1; n <= 4; n++) {
    ingredients['topping' + n] = () => {
      const pizza = main.pizza, hand = main.hand, m = mouse();
      hand.gotoAndStop(g.candyMODE ? `topping${n}candy` : `topping${n}`);
      if (hand.topping) hand.topping.gotoAndStop(g.toppingframe);
      if (pizza.hitTest(m.x, m.y, true) && g.mouseisdown === false && g.perfectpizza === false) {
        const s = pizza.topping.attachMovie('toppings', 'splat' + g.toppingsN, g.toppingsN);
        s._x = m.x - pizza._x;
        s._y = m.y - pizza._y;
        s.gotoAndStop(g.candyMODE ? `topping${n}candy` : `topping${n}`);
        if (s.topping) s.topping.gotoAndStop(g.toppingframe);
        g.toppingSound.start(0, 1);
        g.toppingsN += 1;
        if (g.toppingsN > -2) g.toppingsN = -300;
        g['topping' + n] += 1;
        g.ingredient = 'none';
      } else if (g.mouseisdown === false) {
        g.ingredient = 'none';
        hand.gotoAndStop('none');
        g[`topping${n}Thrown`] = true;
        checkForMessOfKitchen();
        dropTopping(dropFor[n][g.candyMODE ? 1 : 0], true, g.toppingframe);
      }
    };
  }
  function checkForMessOfKitchen() {
    if (g.earnedFoodFiasco) return;
    if (g.sauce0Thrown && g.sauce1Thrown && g.topping0Thrown && g.topping1Thrown && g.topping2Thrown && g.topping3Thrown && g.topping4Thrown) {
      g.messOfKitchen = true;
      if (g.failures === 3) g.earnedFoodFiasco = true;   // (the "Food Fiasco" stamp)
    }
  }

  P.onFrame('main', 3, () => {
    main.stop();
    svgEl.classList.add('playing');
    main.status_made.text = T('status_made');
    main.status_left.text = T('status_left');
    main.status_mistakes.text = T('status_mistakes');
    main.score_coins.text = T('score_coins');
    Object.assign(g, {
      quit: false, consecutivePizzas: 0, speedboost: 0, gameplay: true, score: 0, servedpizzas: 0, tips: 0, coins: 0, failures: 0,
      handicap: 0, possibleorders: 2, maxpossibleorders: 24, splatN: -300, toppingsN: -300, dropN: 1001, dropspeedY: 20, dropspeedX: 0,
      ingredient: 'none', mouseisdown: false, normalsaucePLACED: false, hotsaucePLACED: false, cheesePLACED: false,
      topping1: 0, topping2: 0, topping3: 0, topping4: 0, toppingframe: 1,
      perfecttopping1: false, perfecttopping2: false, perfecttopping3: false, perfecttopping4: false, perfectpizza: false,
      order: 1, ordersmade: 0, pizzasmade: 0, pizzasleft: 40,
      normalsauceREQUESTED: false, hotsauceREQUESTED: false, cheeseREQUESTED: false,
      topping1REQUESTED: false, Ntopping1REQUESTED: 0, topping2REQUESTED: false, Ntopping2REQUESTED: 0,
      topping3REQUESTED: false, Ntopping3REQUESTED: 0, topping4REQUESTED: false, Ntopping4REQUESTED: 0,
      sauce0Thrown: false, sauce1Thrown: false, topping0Thrown: false, topping1Thrown: false, topping2Thrown: false, topping3Thrown: false, topping4Thrown: false,
      messOfKitchen: false, earnedFoodFiasco: false, pizzaspeed: 1, strengthX: 0, strengthY: 0,
      handposX: 0, handposX1: 0, handposX2: 0, handposY: 0, handposY1: 0, handposY2: 0,
    });
    for (let i = 0; i <= 30; i++) g['perfectpizzas' + i] = false;
    for (let t = 1001; t < 1021; t++) { g['dropspeedY' + t] = g.dropspeedY; g['dropspeedX' + t] = g.dropspeedX; }
    g.toppingSound = P.sound('3');
    g.chachingSound = P.sound('4');
    g.zipSound = P.sound('zip');
    const hand = main.attachMovie('hand', 'hand', 1000);
    hand._x = mouse().x; hand._y = mouse().y;
    showVars();
    placepizza();
    if (g.candyMODE === true) {
      main.ingredients_sauces.gotoAndStop('normalcandy');
      main.ingredients_cheese.gotoAndStop('sprinkles');
      main.ingredients_topping1.gotoAndStop('liquorice');
      main.ingredients_topping2.gotoAndStop('chocolatechips');
      main.ingredients_topping3.gotoAndStop('marshmellows');
      main.ingredients_topping4.gotoAndStop('jellybeans');
      main.orderscreen.gotoAndStop(25);
    }

    main.onEnterFrame = function () {
      if (g.gameplay !== true) return;
      const m = mouse();
      main.hand._x = m.x; main.hand._y = m.y;
      modes[g.gameMODE]();
      if (!main.pizza) return;        // (removepizza just took it; the next frame places a new one)
      ingredients[g.ingredient]();
      g.coins = g.score + g.tips;
      const pizza = main.pizza;
      // sauce overflow: hold the bottle too long and the pizza floods
      if (g.splatN > -111) {
        g.pizzaspeed += 1;
        if (g.normalsaucePLACED) pizza.overflow.gotoAndStop(g.candyMODE ? 'explodecandy' : 'explode');
        else if (g.hotsaucePLACED) pizza.overflow.gotoAndStop(g.candyMODE ? 'explodehotcandy' : 'explodehot');
      } else {
        const h = g.handicap, c = g.candyMODE ? 1 : 0;
        g.pizzaspeed = !(h > -2) ? 1 + c : !(h > -1) ? 2 + c : !(h > 4) ? 3 + c : !(h > 8) ? 4 + c : !(h > 13) ? 5 + c : !(h > 19) ? 6 + c : !(h > 26) ? 7 + c : !(h > 34) ? 8 + c : g.pizzaspeed;
      }
      const os = main.orderscreen;
      if (os.sauce) os.sauce.gotoAndStop(g.normalsaucePLACED === true ? 'check' : 'none');
      if (os.hotsauce) os.hotsauce.gotoAndStop(g.hotsaucePLACED === true ? 'check' : 'none');
      if (os.cheese) os.cheese.gotoAndStop(g.cheesePLACED === true ? 'check' : 'none');
      for (let n = 1; n <= 4; n++) if (os['top' + n]) os['top' + n].gotoAndStop(!(g['topping' + n] < g[`Ntopping${n}REQUESTED`]) ? 'check' : 'none');
      if (g.normalsaucePLACED === true) pizza.base.gotoAndStop(g.candyMODE ? 'chocolatesauce' : 'normalsauce');
      else if (g.hotsaucePLACED === true) pizza.base.gotoAndStop(g.candyMODE ? 'pinkicing' : 'hotsauce');
      else pizza.base.gotoAndStop('empty');
      // mouse momentum for thrown ingredients
      g.handposY2 = g.handposY1; g.handposY1 = g.handposY; g.handposY = m.y;
      g.handposX2 = g.handposX1; g.handposX1 = g.handposX; g.handposX = m.x;
      g.strengthY = (g.handposY2 - g.handposY + 60) / 3;
      if (g.strengthY > 40) g.strengthY = 40; else if (g.strengthY < -20) g.strengthY = -20;
      g.strengthX = (g.handposX2 - g.handposX) / 3;
      if (g.strengthX > 30) g.strengthX = 30; else if (g.strengthX < -30) g.strengthX = -30;
      for (let t = 1001; t < 1011; t++) {
        const sy = 'dropspeedY' + t, sx = 'dropspeedX' + t;
        if (Math.round(g[sy]) > 20) g[sy] -= 1; else if (Math.round(g[sy]) < 20) g[sy] += 1; else g[sy] = 20;
        const d = main['droppedtopping' + t];
        if (d) d._y += g[sy];
        if (Math.round(g[sx]) > 0) g[sx] -= 0.5; else if (Math.round(g[sx]) < 0) g[sx] += 0.5; else g[sx] = 0;
        if (d) { d._x += g[sx]; if (g['droprotate' + t] === true) d._rotation += g[sx]; }
      }
      showVars();
      if (!(g.failures < 5)) {
        g.gameplay = false;
        main.gotoAndStop(!(g.pizzasmade > 1) ? 'endlame' : 'endlose');
      }
      if (!(g.ordersmade < 40)) {
        g.gameplay = false;
        main.gotoAndStop(!(g.pizzasmade < 40) ? 'endperfect' : 'endwin');
      }
    };
  });

  // ingredient buttons (press): pick up / put back
  const pick = (name, extra) => (btn) => {
    if (g.ingredient === name) { g.ingredient = 'none'; return; }
    g.ingredient = name;
    if (extra) extra();
  };
  P.onButton(608, pick('normalsauce'));
  P.onButton(609, pick('hotsauce'));
  P.onButton(610, pick('cheese', () => main.ingredients_sauces.gotoAndStop(g.candyMODE ? 'candy' : 'normal')));
  for (let n = 1; n <= 4; n++) P.onButton(610 + n, pick('topping' + n, () => { main.ingredients_sauces.gotoAndStop(g.candyMODE ? 'candy' : 'normal'); g.toppingframe = random(3) + 1; }));
  P.onButton(650, () => { g.quit = true; g.gameplay = false; main.gotoAndStop('title'); });   // quit

  P.onMouseDown = () => { g.mouseisdown = true; };
  P.onMouseUp = () => { g.mouseisdown = false; };

  // ---- results screens (frames 4-7) ---------------------------------------------------
  const results = (main) => {
    main.stop();
    svgEl.classList.remove('playing');
    for (const [name, key] of [['score_label', 'score_score'], ['perfectscore_label', 'score_perfectscore'], ['sold_label', 'score_sold'], ['sales_label', 'score_sales'],
      ['tips_label', 'score_tips'], ['total_label', 'score_total'], ['coins1_label', 'score_coins'], ['coins2_label', 'score_coins'], ['coins3_label', 'score_coins'], ['ui_done', 'ui_done']])
      if (main[name]) main[name].text = T(key);
    main.pizzasmadeText.text = g.pizzasmade;
    main.scoreText.text = g.score;
    main.tipsText.text = g.tips;
    main.earningsText.text = g.coins;
    g.gameMODE = 'gameover';
    if (main.pizza) main.pizza.removeMovieClip();
    if (main.hand) main.hand.gotoAndStop('none');
    for (let t = 1001; t < 1101; t++) if (main['droppedtopping' + t]) main['droppedtopping' + t].removeMovieClip();
    if (g.mySound) g.mySound.stop();
    dbg('game over', main._currentframe, 'made', g.pizzasmade, 'coins', g.coins);
    // the arcade shell pays out tickets for the shift (frontend/src/lib/tickets.ts)
    const ending = !(g.failures < 5) ? (g.pizzasmade > 1 ? 'lose' : 'lame') : (g.pizzasmade < 40 ? 'win' : 'perfect');
    if (window.parent !== window) window.parent.postMessage({ type: 'arcade:round', game: 'pizzatron', pizzas: g.pizzasmade, ending }, location.origin);
  };
  for (const f of [4, 5, 6, 7]) P.onFrame('main', f, results);

  P.g = g;   // (state, for the console / playtest bots)
  P.start();
  return P;
}
