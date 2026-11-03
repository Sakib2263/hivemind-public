// ---------- compositor ----------
const TW = 0.6; // transition window (s)
function transType(a, b) {
  // Project scenes.js may define TRANS = { 'sceneA>sceneB': 'flash', ... } and TRANS_DEFAULT.
  const T = (typeof TRANS !== 'undefined') ? TRANS : {};
  return T[a + '>' + b] || (typeof TRANS_DEFAULT !== 'undefined' ? TRANS_DEFAULT : 'slide');
}
let cvA, cvB, cxA, cxB, MAIN, MX;
function setup() {
  MAIN = document.getElementById('c'); MX = MAIN.getContext('2d');
  cvA = new OffscreenCanvas(W, H); cxA = cvA.getContext('2d');
  cvB = new OffscreenCanvas(W, H); cxB = cvB.getContext('2d');
  makeGrid();
}
function drawScene(ctx, sc, t) {
  ctx.save(); ctx.clearRect(0, 0, W, H);
  SC[sc.id].draw(ctx, t - sc.start, sc.dur, sc);
  ctx.restore();
}
function frame(t) {
  G = t;
  const S = TL.scenes;
  let i = S.findIndex(s => t < s.start + s.dur); if (i < 0) i = S.length - 1;
  const cur = S[i];
  // transition?
  let tr = null;
  if (i > 0 && t - cur.start < TW / 2) tr = [S[i - 1], cur];
  else if (i < S.length - 1 && cur.start + cur.dur - t < TW / 2) tr = [cur, S[i + 1]];
  MX.setTransform(1, 0, 0, 1, 0, 0); MX.globalAlpha = 1; MX.filter = 'none';
  if (!tr) { drawScene(MX, cur, t); }
  else {
    const [A, B] = tr, Bt = B.start, type = transType(A.id, B.id);
    const p = clamp((t - (Bt - TW / 2)) / TW), e = eio(p);
    drawScene(cxA, A, t); drawScene(cxB, B, t);
    MX.fillStyle = '#0F0E1C'; MX.fillRect(0, 0, W, H);
    if (type === 'fade') { MX.drawImage(cvA, 0, 0); MX.globalAlpha = e; MX.drawImage(cvB, 0, 0); MX.globalAlpha = 1; }
    else if (type === 'slide') {
      MX.drawImage(cvA, -e * W * .35, 0); MX.globalAlpha = 1;
      MX.save(); MX.beginPath(); MX.rect(W * (1 - e), 0, W, H); MX.clip(); MX.drawImage(cvB, (1 - e) * W * .65, 0); MX.restore();
      // leading edge bar
      const x = W * (1 - e); const g = MX.createLinearGradient(x - 40, 0, x + 6, 0); g.addColorStop(0, hexA(C.brand, 0)); g.addColorStop(1, hexA(C.teal, .9 * Math.sin(p * Math.PI)));
      MX.fillStyle = g; MX.fillRect(x - 40, 0, 46, H);
    }
    else if (type === 'zoom') {
      MX.save(); MX.globalAlpha = 1 - e; MX.translate(W / 2, H / 2); MX.scale(1 + e * .25, 1 + e * .25); MX.drawImage(cvA, -W / 2, -H / 2); MX.restore();
      MX.save(); MX.globalAlpha = e; MX.translate(W / 2, H / 2); MX.scale(.85 + e * .15, .85 + e * .15); MX.drawImage(cvB, -W / 2, -H / 2); MX.restore();
    }
    else if (type === 'iris') {
      MX.drawImage(cvA, 0, 0);
      const r = e * Math.hypot(W, H) * .53; MX.save(); MX.beginPath(); MX.arc(W / 2, H / 2, r, 0, Math.PI * 2); MX.clip(); MX.drawImage(cvB, 0, 0); MX.restore();
      MX.save(); MX.strokeStyle = hexA(C.teal, Math.sin(p * Math.PI)); MX.lineWidth = 10; MX.beginPath(); MX.arc(W / 2, H / 2, r, 0, Math.PI * 2); MX.stroke(); MX.restore();
    }
    else if (type === 'wipe') {
      const x = lerp(-W * .6, W * 1.6, e), sk = 300;
      MX.drawImage(cvB, 0, 0);
      MX.save(); MX.beginPath(); MX.moveTo(x, 0); MX.lineTo(W + sk, 0); MX.lineTo(W + sk, H); MX.lineTo(x - sk, H); MX.closePath(); MX.clip(); MX.drawImage(cvA, 0, 0); MX.restore();
      [[C.brand, 0], [C.teal, 90], [C.amber, 150]].forEach(([col, off]) => {
        MX.fillStyle = col; MX.beginPath(); MX.moveTo(x - off, 0); MX.lineTo(x - off - (off === 0 ? 90 : 30), 0); MX.lineTo(x - off - (off === 0 ? 90 : 30) - sk, H); MX.lineTo(x - off - sk, H); MX.closePath(); MX.fill();
      });
    }
    else if (type === 'flash') {
      MX.drawImage(p < .5 ? cvA : cvB, 0, 0);
      MX.fillStyle = `rgba(255,255,255,${Math.sin(p * Math.PI) * .95})`; MX.fillRect(0, 0, W, H);
    }
  }
  drawCaptions(MX, t, cur);
}
function drawCaptions(ctx, t, sc) {
  if (!window.SHOW_CAPS || (typeof NO_CAPS !== 'undefined' && NO_CAPS.includes(sc.id))) return;
  const lt = t - sc.start;
  const c = sc.caps.find(c => lt >= c.t0 - .05 && lt <= c.t1 + .25); if (!c) return;
  const a = Math.min(P(lt, c.t0 - .05, c.t0 + .1, lin), 1 - P(lt, c.t1 + .1, c.t1 + .25, lin));
  // portrait: bigger text, kept above the Shorts/Reels buttons and title (bottom ~440 px)
  const fs = VERT ? 48 : 34, lh = VERT ? 62 : 46, maxW = Math.min(1400, W - (VERT ? 140 : 200));
  const lines = wrap(ctx, c.text, maxW, fs, 600);
  ctx.save(); ctx.globalAlpha = a;
  const h = lines.length * lh + 28, y0 = (VERT ? H - 440 : H - 30) - h;
  const w = Math.max(...lines.map(l => tw(ctx, l, fs, 600))) + 64;
  fillRR(ctx, W / 2 - w / 2, y0, w, h, 18, 'rgba(10,9,24,0.78)');
  lines.forEach((l, i) => txt(ctx, l, W / 2, y0 + 14 + fs + i * lh, fs, { a: 'center', w: 600 }));
  ctx.restore();
}
function allCues() {
  const out = [];
  TL.scenes.forEach((sc, i) => {
    (SC[sc.id].cues ? SC[sc.id].cues(sc.dur, sc) : []).forEach(([t, type, g]) => { if (t >= 0 && t <= sc.dur + .2) out.push([+(sc.start + t).toFixed(3), type, g]); });
    if (i > 0) {
      const tt = transType(TL.scenes[i - 1].id, sc.id);
      if (tt === 'slide' || tt === 'zoom' || tt === 'wipe' || tt === 'iris') out.push([+(sc.start - .32).toFixed(3), tt === 'wipe' ? 'whoosh_big' : 'whoosh', tt === 'slide' ? .45 : .6]);
      if (tt === 'flash') out.push([+(sc.start - .05).toFixed(3), 'flashhit', .7]);
    }
  });
  return out.sort((a, b) => a[0] - b[0]);
}
async function init(cutName, showCaps) {
  window.SHOW_CAPS = showCaps;
  const all = await (await fetch('timeline.json')).json();
  TL = all[cutName]; CUT = cutName; setSize(TL.w, TL.h);
  const fonts = [['Poppins', 'Poppins-Bold.ttf', 700], ['Poppins', 'Poppins-Medium.ttf', 500], ['Inter', 'Inter-Regular.otf', 400], ['Inter', 'Inter-Medium.otf', 500],
    ['Inter', 'Inter-SemiBold.otf', 600], ['Inter', 'Inter-Bold.otf', 700], ['Inter', 'Inter-ExtraBold.otf', 800]];
  for (const [fam, file, w] of fonts) {
    const f = new FontFace(fam, `url(fonts/${file})`, { weight: '' + w }); await f.load(); document.fonts.add(f);
  }
  try { LOGO = new Image(); LOGO.src = 'assets/logo.png'; await LOGO.decode(); } catch (e) { LOGO = null; }
  if (typeof onInit === 'function') await onInit();
  setup();
  return TL.total;
}
