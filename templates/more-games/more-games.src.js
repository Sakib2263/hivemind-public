/* More games + exit prompt for Your Studio web games (browser, Playgama, Android/Capacitor).
   Drop-in: <script src="more-games.js"></script>, then MoreGames.init({...}) once the page is ready.
   Generated from hivemind/templates/more-games/ (games.json + more-games.src.js). Edit the source, not the copy. */
(function () {
  const GAMES = __GAMES__;
  const store = id => 'https://play.google.com/store/apps/details?id=' + id;
  const opt = { selfId: '', title: 'Leaving already?', note: 'Your progress is saved.', stay: 'Keep playing', exit: 'Exit',
    max: 4, listTitle: 'More games', closeLabel: 'Close', onBack: null, onExit: null, sound: null, accent: '#FFD966', ink: '#4B3E66', paper: '#FFFBF5', mascot: '' };
  let wrap = null, armed = false;

  function css() {
    if (document.getElementById('mg-css')) return;
    const st = document.createElement('style'); st.id = 'mg-css';
    st.textContent = `
#mg-wrap{position:fixed;inset:0;z-index:9000;display:flex;align-items:center;justify-content:center;padding:16px;background:rgba(40,30,60,.38);animation:mgFade .22s}
#mg-wrap.out{opacity:0;transition:opacity .2s}
.mg-sheet{width:100%;max-width:380px;border-radius:28px;background:var(--mg-paper);color:var(--mg-ink);padding:22px 18px 18px;text-align:center;box-shadow:0 8px 0 rgba(0,0,0,.08),0 24px 50px rgba(0,0,0,.25);animation:mgPop .45s cubic-bezier(.2,1.5,.4,1);font-family:inherit}
#mg-wrap.out .mg-sheet{transform:scale(.8);transition:transform .2s}
.mg-head{display:flex;align-items:center;justify-content:center;gap:10px}.mg-head svg,.mg-head img{width:56px;height:56px;flex:none}
.mg-sheet h3{margin:0;font-size:28px;line-height:1.05}
.mg-note{margin:8px 0 0;font-size:14px;opacity:.7}
.mg-lab{margin:14px 0 0;font-size:12px;letter-spacing:.12em;text-transform:uppercase;opacity:.7;font-weight:800}
.mg-row{display:flex;justify-content:center;gap:10px;margin-top:10px}
.mg-g{width:70px;display:flex;flex-direction:column;align-items:center;gap:4px;color:inherit;text-decoration:none;font-size:11px;line-height:1.1;font-weight:800;animation:mgPop .45s cubic-bezier(.3,1.4,.5,1) backwards}
.mg-g:nth-child(2){animation-delay:.08s}.mg-g:nth-child(3){animation-delay:.16s}.mg-g:nth-child(4){animation-delay:.24s}
.mg-g img{width:58px;height:58px;border-radius:14px;box-shadow:0 4px 0 rgba(0,0,0,.08)}
.mg-acts{display:flex;flex-direction:column;gap:22px;margin-top:20px}
.mg-btn{min-height:54px;border:0;border-radius:999px;font:inherit;font-size:20px;font-weight:800;color:var(--mg-ink);background:var(--mg-accent);box-shadow:0 6px 0 rgba(0,0,0,.14)}
.mg-btn.ghost{background:#fff;box-shadow:0 6px 0 rgba(0,0,0,.07)}
.mg-btn:active{transform:translateY(4px) scale(.97);box-shadow:0 2px 0 rgba(0,0,0,.1)}
.mg-list{display:flex;flex-direction:column;gap:10px;width:100%}
.mg-item{display:flex;align-items:center;gap:12px;padding:10px 12px;border-radius:18px;background:var(--mg-paper);color:var(--mg-ink);text-decoration:none;box-shadow:0 4px 0 rgba(0,0,0,.06)}
.mg-item img{width:56px;height:56px;border-radius:14px;flex:none}.mg-item b{flex:1;font-size:16px;text-align:left}
.mg-item span{padding:8px 16px;border-radius:999px;background:var(--mg-accent);font-weight:800;font-size:14px}
.mg-full{display:flex;flex-direction:column;max-height:calc(100vh - 32px);max-height:calc(100dvh - 32px)}
.mg-full .mg-list{flex:1 1 auto;min-height:0;overflow-y:auto;touch-action:pan-y;overscroll-behavior:contain;-webkit-overflow-scrolling:touch;margin-top:14px;padding:4px 2px 8px}
.mg-full .mg-item{background:#fff}.mg-full .mg-acts{margin-top:14px}
@keyframes mgFade{from{opacity:0}}@keyframes mgPop{0%{transform:scale(.4);opacity:0}60%{transform:scale(1.06);opacity:1}100%{transform:none}}
@media (prefers-reduced-motion:reduce){#mg-wrap,.mg-sheet,.mg-g{animation:none}}`;
    document.head.appendChild(st);
  }
  const list = () => GAMES.filter(g => g.id !== opt.selfId);
  const items = () => list().map(g => `<a class="mg-item" href="${store(g.id)}" data-mg="${g.id}"><img alt="" src="${g.icon}" loading="lazy"><b>${g.name}</b><span>Get</span></a>`).join('');
  function open(id) { // native store app on Android, web page elsewhere
    if (window.AndroidApp && AndroidApp.openStore) AndroidApp.openStore(id); else window.open(store(id), '_blank', 'noopener');
  }
  function bindLinks(root) {
    root.querySelectorAll('[data-mg]').forEach(a => a.addEventListener('click', e => { e.preventDefault(); opt.sound && opt.sound(); open(a.dataset.mg); }));
  }
  function close() {
    if (!wrap) return; const w = wrap; wrap = null; armed = false;
    w.classList.add('out'); setTimeout(() => w.remove(), 200);
  }
  function exitNow() {
    try { opt.onExit && opt.onExit(); } catch (e) {}
    if (window.AndroidApp && AndroidApp.exit) AndroidApp.exit(); else close();
  }
  function showExit() {
    css(); if (wrap) return;
    const games = list().slice(0, opt.max);
    wrap = document.createElement('div'); wrap.id = 'mg-wrap';
    wrap.style.cssText = `--mg-accent:${opt.accent};--mg-ink:${opt.ink};--mg-paper:${opt.paper}`;
    wrap.innerHTML = `<div class="mg-sheet" role="dialog" aria-modal="true"><div class="mg-head">${opt.mascot}<h3>${opt.title}</h3></div>
      <p class="mg-note">${opt.note}</p>
      ${games.length ? `<p class="mg-lab">Try our other games</p><div class="mg-row">${games.map(g => `<a class="mg-g" href="${store(g.id)}" data-mg="${g.id}"><img alt="" src="${g.icon}"><span>${g.name}</span></a>`).join('')}</div>` : ''}
      <div class="mg-acts"><button class="mg-btn" data-k="stay">${opt.stay}</button><button class="mg-btn ghost" data-k="exit">${opt.exit}</button></div></div>`;
    document.body.appendChild(wrap); bindLinks(wrap); armed = true;
    wrap.querySelector('[data-k=stay]').onclick = () => { opt.sound && opt.sound(); close(); };
    wrap.querySelector('[data-k=exit]').onclick = () => { opt.sound && opt.sound(); exitNow(); };
    wrap.addEventListener('pointerdown', e => { if (e.target === wrap) close(); });
  }
  function showList() { // full-screen "More games" list; Close, back or tapping outside closes it
    css(); if (wrap) return;
    wrap = document.createElement('div'); wrap.id = 'mg-wrap';
    wrap.style.cssText = `--mg-accent:${opt.accent};--mg-ink:${opt.ink};--mg-paper:${opt.paper}`;
    wrap.innerHTML = `<div class="mg-sheet mg-full" role="dialog" aria-modal="true"><h3>${opt.listTitle}</h3>
      <div class="mg-list">${items()}</div>
      <div class="mg-acts"><button class="mg-btn" data-k="close">${opt.closeLabel}</button></div></div>`;
    document.body.appendChild(wrap); bindLinks(wrap); armed = false;
    wrap.querySelector('[data-k=close]').onclick = () => { opt.sound && opt.sound(); close(); };
    wrap.addEventListener('pointerdown', e => { if (e.target === wrap) close(); });
  }
  // Native back (MainActivity) calls window.onAndroidBack(); return 'exit' to close the app.
  window.onAndroidBack = function () {
    if (wrap) { if (armed) { exitNow(); return 'exit'; } close(); return ''; }
    if (opt.onBack && opt.onBack() === true) return ''; // the game handled it (closed a panel, went back a screen)
    showExit(); return '';
  };
  window.MoreGames = {
    games: list,
    init(o) { Object.assign(opt, o || {}); css(); return this; },
    showExit,
    showList,
    isOpen: () => !!wrap,
    close,
    renderList(el) { // full "More games" screen list into a container
      css(); if (!el) return;
      el.classList.add('mg-list');
      el.style.cssText += `;--mg-accent:${opt.accent};--mg-ink:${opt.ink};--mg-paper:${opt.paper}`;
      el.innerHTML = items();
      bindLinks(el);
    },
  };
})();
