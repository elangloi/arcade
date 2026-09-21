// Arcade nav bar: one script tag on every page (<script src="/nav/nav.js" defer></script>) puts the
// same slim bar at the top, with links to the front page, each single-player cabinet and the
// multiplayer lobby, and highlights where you are. Self-contained: injects its own CSS.
(function () {
  const HERE = location.pathname;
  const GAMES = [
    ['Battle Blitz', '/teen-titans-battle-blitz/'],
    ['Sandwich Stacker', '/lilo-and-stitch-sandwich-stacker/'],
    ['Pizzatron', '/club-penguin-pizzatron/'],
    ['Noby Noby Boy', '/noby-noby-boy/'],
  ];
  const MP = '/arcade/multiplayer/';
  const isMp = HERE.startsWith(MP) || HERE.includes('/multiplayer/') || location.port === '8766';
  const isHome = HERE === '/' || HERE === '/index.html';
  const gameHere = GAMES.find(([, href]) => HERE.startsWith(href)) || (HERE.match(/^\/(battleblitz|sandwichstacker|pizzatron|nobynobyboy)\//) && GAMES[['battleblitz', 'sandwichstacker', 'pizzatron', 'nobynobyboy'].indexOf(HERE.split('/')[1])]);

  const css = `
    @font-face { font-family: "Fredoka"; font-weight: 700; font-display: swap; src: url(/fonts/fredoka-700.woff2) format("woff2"); }
    #arcade-nav { position: fixed; top: 0; left: 0; right: 0; z-index: 9999; height: 38px; display: flex; align-items: center; gap: 6px; padding: 0 14px;
      background: #ff8fcf; color: #2b2450; box-shadow: 0 4px 0 #e86fb3, 0 8px 18px rgba(0,0,0,.35);
      font: 700 12px/1 "Fredoka", ui-rounded, "SF Pro Rounded", "Arial Rounded MT Bold", system-ui, sans-serif; letter-spacing: .06em; text-transform: uppercase; white-space: nowrap; overflow-x: auto; }
    #arcade-nav a { color: inherit; text-decoration: none; padding: 6px 10px; border-radius: 999px; transition: background .12s, transform .12s; }
    #arcade-nav a:hover { background: #fbf57a; transform: translateY(-1px); }
    #arcade-nav a.here { background: #151747; color: #fbf57a; box-shadow: inset 0 -2px 0 #0d0f30; }
    #arcade-nav .home { font-size: 13px; padding-left: 8px; }
    #arcade-nav .home svg { width: 14px; height: 14px; vertical-align: -2px; margin-right: 4px; }
    #arcade-nav .sep { width: 2px; height: 18px; background: #e86fb3; border-radius: 1px; margin: 0 4px; flex: none; }
    #arcade-nav .lbl { opacity: .65; font-size: 10px; letter-spacing: .12em; margin-right: 2px; }
    #arcade-nav .spacer { flex: 1; }
    #arcade-nav .coin { width: 10px; height: 10px; border-radius: 50%; background: #fbf57a; box-shadow: inset -2px -2px 0 #e5c94d; flex: none; animation: arcade-nav-blink 1.2s steps(2) infinite; }
    @keyframes arcade-nav-blink { to { opacity: 0; } }
    body { padding-top: 38px !important; }
    @media (prefers-reduced-motion: reduce) { #arcade-nav .coin { animation: none; } }
  `;
  const star = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5 14.6 9.4 22.5 12 14.6 14.6 12 22.5 9.4 14.6 1.5 12 9.4 9.4Z" fill="currentColor"/></svg>';
  const link = (label, href, here, cls = '') => `<a class="${cls}${here ? ' here' : ''}" href="${href}">${label}</a>`;

  const html = `
    ${link(star + 'Arcade', '/', isHome, 'home')}
    <span class="sep"></span>
    <span class="lbl">1P</span>
    ${GAMES.map(g => link(g[0], g[1], gameHere && gameHere[1] === g[1])).join('')}
    <span class="sep"></span>
    <span class="lbl">2P</span>
    ${link('Multiplayer', MP, isMp && !HERE.includes('lobby') && !HERE.includes('/games/'))}
    ${link('Battle Blitz lobby', MP + 'lobby.html', isMp && (HERE.includes('lobby') || HERE.includes('/games/')))}
    <span class="spacer"></span>
    <span class="coin"></span>
  `;
  const style = document.createElement('style'); style.textContent = css;
  const nav = document.createElement('nav'); nav.id = 'arcade-nav'; nav.setAttribute('aria-label', 'Arcade'); nav.innerHTML = html;
  document.head.appendChild(style);
  document.body.prepend(nav);
})();
