// motion-video-producer canvas engine (generic). Brand marks / project HUDs live in each project's scenes.js.
// first built for a product explainer (deterministic: frame(t) draws time t)
let W = 1920, H = 1080, VERT = false;   // set per cut by setSize() from timeline.json (16:9, 9:16, 1:1)
// A y position from the 1920x1080 design, re-centred for any size (portrait spreads content a bit more).
const vy = y => H * (VERT ? .44 : .5) + (y - 540) * (VERT ? 1.3 : 1);
function setSize(w, h) {
  W = w || 1920; H = h || 1080; VERT = H > W;
  const c = document.getElementById('c'); if (c) { c.width = W; c.height = H; }
}
const C = {
  brand: '#5B4FE8', violet: '#8B7FFF', teal: '#00C9A7', amber: '#F5A623', red: '#E24B4A',
  dark: '#0F0E1C', dark2: '#17152E', card: '#1E1C3A', card2: '#26234A', line: '#34315E',
  surface: '#F4F3FF', white: '#FFFFFF', muted: '#A9A6CC', dim: '#6E6A99', skin: '#C68B59', hair: '#2A1E1A'
};
const FD = 'Poppins', FB = 'Inter';
let G = 0;               // global time
let TL = null, CUT = null;

// ---------- math ----------
const clamp = (v, a = 0, b = 1) => Math.max(a, Math.min(b, v));
const lerp = (a, b, p) => a + (b - a) * p;
const eoc = p => 1 - Math.pow(1 - p, 3);
const eio = p => p < .5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2;
const eob = p => { const c1 = 1.70158, c3 = c1 + 1; return 1 + c3 * Math.pow(p - 1, 3) + c1 * Math.pow(p - 1, 2); };
const eel = p => p === 0 ? 0 : p === 1 ? 1 : Math.pow(2, -10 * p) * Math.sin((p * 10 - .75) * (2 * Math.PI / 3)) + 1;
const lin = p => p;
function P(t, a, b, e = eoc) { return e(clamp((t - a) / Math.max(1e-6, b - a))); }
function rnd(i) { const x = Math.sin(i * 127.1 + 311.7) * 43758.5453; return x - Math.floor(x); }
function hexA(hex, a) {
  const n = parseInt(hex.slice(1), 16);
  return `rgba(${n >> 16 & 255},${n >> 8 & 255},${n & 255},${a})`;
}

// ---------- drawing primitives ----------
function rr(ctx, x, y, w, h, r) {
  r = Math.min(r, w / 2, h / 2);
  ctx.beginPath(); ctx.moveTo(x + r, y); ctx.arcTo(x + w, y, x + w, y + h, r); ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r); ctx.arcTo(x, y, x + w, y, r); ctx.closePath();
}
function fillRR(ctx, x, y, w, h, r, fill, stroke, lw = 2) {
  rr(ctx, x, y, w, h, r);
  if (fill) { ctx.fillStyle = fill; ctx.fill(); }
  if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = lw; ctx.stroke(); }
}
function txt(ctx, s, x, y, size, o = {}) {
  ctx.save();
  ctx.font = `${o.w || 600} ${size}px ${o.f || FB}`;
  ctx.fillStyle = o.c || C.white;
  ctx.textAlign = o.a || 'left';
  ctx.textBaseline = o.b || 'alphabetic';
  if (o.ls) ctx.letterSpacing = o.ls + 'px';
  if (o.alpha !== undefined) ctx.globalAlpha *= o.alpha;
  if (o.glow) { ctx.shadowColor = o.glow; ctx.shadowBlur = o.gb || 30; }
  ctx.fillText(s, x, y);
  ctx.restore();
}
function tw(ctx, s, size, w = 600, f = FB, ls = 0) {
  ctx.save(); ctx.font = `${w} ${size}px ${f}`; if (ls) ctx.letterSpacing = ls + 'px';
  const m = ctx.measureText(s).width; ctx.restore(); return m;
}
function wrap(ctx, s, maxW, size, w = 600, f = FB) {
  const words = s.split(' '); const lines = []; let cur = '';
  for (const wd of words) {
    const tst = cur ? cur + ' ' + wd : wd;
    if (tw(ctx, tst, size, w, f) > maxW && cur) { lines.push(cur); cur = wd; } else cur = tst;
  }
  if (cur) lines.push(cur); return lines;
}
function glowDot(ctx, x, y, r, col, a = 1) {
  const g = ctx.createRadialGradient(x, y, 0, x, y, r);
  g.addColorStop(0, hexA(col, .9 * a)); g.addColorStop(.35, hexA(col, .35 * a)); g.addColorStop(1, hexA(col, 0));
  ctx.fillStyle = g; ctx.beginPath(); ctx.arc(x, y, r, 0, Math.PI * 2); ctx.fill();
}
function circle(ctx, x, y, r, fill, stroke, lw = 2) {
  ctx.beginPath(); ctx.arc(x, y, Math.max(0, r), 0, Math.PI * 2);
  if (fill) { ctx.fillStyle = fill; ctx.fill(); }
  if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = lw; ctx.stroke(); }
}
function arrow(ctx, x1, y1, x2, y2, col, lw = 4, head = 16, p = 1) {
  const x = lerp(x1, x2, p), y = lerp(y1, y2, p);
  ctx.save(); ctx.strokeStyle = col; ctx.fillStyle = col; ctx.lineWidth = lw; ctx.lineCap = 'round';
  ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x, y); ctx.stroke();
  if (p > .15) {
    const a = Math.atan2(y2 - y1, x2 - x1);
    ctx.beginPath(); ctx.moveTo(x + Math.cos(a) * 2, y + Math.sin(a) * 2);
    ctx.lineTo(x - Math.cos(a - .5) * head, y - Math.sin(a - .5) * head);
    ctx.lineTo(x - Math.cos(a + .5) * head, y - Math.sin(a + .5) * head); ctx.closePath(); ctx.fill();
  }
  ctx.restore();
}
function withT(ctx, x, y, s, rot, fn, alpha = 1) {
  if (alpha <= 0.001 || s <= 0.001) return;
  ctx.save(); ctx.translate(x, y); if (rot) ctx.rotate(rot); ctx.scale(s, s); ctx.globalAlpha *= clamp(alpha); fn(); ctx.restore();
}
function check(ctx, x, y, s, col = C.teal, p = 1) {
  ctx.save(); ctx.strokeStyle = col; ctx.lineWidth = s * .16; ctx.lineCap = 'round'; ctx.lineJoin = 'round';
  const pts = [[-.35, 0], [-.1, .28], [.4, -.3]];
  ctx.beginPath(); ctx.moveTo(x + pts[0][0] * s, y + pts[0][1] * s);
  const L1 = .38, L2 = .78, tot = L1 + L2; let d = p * tot;
  if (d <= L1) ctx.lineTo(x + lerp(pts[0][0], pts[1][0], d / L1) * s, y + lerp(pts[0][1], pts[1][1], d / L1) * s);
  else { ctx.lineTo(x + pts[1][0] * s, y + pts[1][1] * s); const q = (d - L1) / L2; ctx.lineTo(x + lerp(pts[1][0], pts[2][0], q) * s, y + lerp(pts[1][1], pts[2][1], q) * s); }
  ctx.stroke(); ctx.restore();
}
function cross(ctx, x, y, s, col = C.red) {
  ctx.save(); ctx.strokeStyle = col; ctx.lineWidth = s * .16; ctx.lineCap = 'round';
  ctx.beginPath(); ctx.moveTo(x - s * .3, y - s * .3); ctx.lineTo(x + s * .3, y + s * .3);
  ctx.moveTo(x + s * .3, y - s * .3); ctx.lineTo(x - s * .3, y + s * .3); ctx.stroke(); ctx.restore();
}

// ---------- icons (centered, size s) ----------
function icon(ctx, name, x, y, s, col = C.white, lw) {
  ctx.save(); ctx.translate(x, y); ctx.strokeStyle = col; ctx.fillStyle = col;
  ctx.lineWidth = lw || Math.max(2, s * .08); ctx.lineCap = 'round'; ctx.lineJoin = 'round';
  const u = s / 2;
  switch (name) {
    case 'game':
      rr(ctx, -u * .9, -u * .45, u * 1.8, u * .95, u * .45); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-u * .55, 0); ctx.lineTo(-u * .25, 0); ctx.moveTo(-u * .4, -u * .15); ctx.lineTo(-u * .4, u * .15); ctx.stroke();
      circle(ctx, u * .35, -u * .07, u * .08, col); circle(ctx, u * .55, u * .1, u * .08, col); break;
    case 'quiz':
      rr(ctx, -u * .8, -u * .75, u * 1.6, u * 1.25, u * .25); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-u * .3, u * .5); ctx.lineTo(-u * .5, u * .85); ctx.lineTo(0, u * .5); ctx.stroke();
      ctx.font = `700 ${u * 1.05}px ${FD}`; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText('?', 0, -u * .08); break;
    case 'ai':
      ctx.beginPath();
      for (const [cx, cy, r] of [[0, 0, u * .75], [u * .62, -u * .55, u * .3]]) {
        ctx.moveTo(cx, cy - r); ctx.quadraticCurveTo(cx, cy, cx + r, cy); ctx.quadraticCurveTo(cx, cy, cx, cy + r);
        ctx.quadraticCurveTo(cx, cy, cx - r, cy); ctx.quadraticCurveTo(cx, cy, cx, cy - r);
      } ctx.fill(); break;
    case 'msg':
      ctx.beginPath(); ctx.moveTo(-u * .8, -u * .25); ctx.lineTo(-u * .35, -u * .25); ctx.lineTo(u * .55, -u * .75); ctx.lineTo(u * .55, u * .55);
      ctx.lineTo(-u * .35, u * .15); ctx.lineTo(-u * .8, u * .15); ctx.closePath(); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-u * .5, u * .15); ctx.lineTo(-u * .35, u * .7); ctx.stroke();
      ctx.beginPath(); ctx.arc(u * .6, -u * .1, u * .35, -.6, .6); ctx.stroke(); break;
    case 'trophy':
      ctx.beginPath(); ctx.moveTo(-u * .5, -u * .75); ctx.lineTo(u * .5, -u * .75); ctx.lineTo(u * .42, -u * .05);
      ctx.quadraticCurveTo(0, u * .35, -u * .42, -u * .05); ctx.closePath(); ctx.stroke();
      ctx.beginPath(); ctx.arc(-u * .55, -u * .45, u * .22, Math.PI * .5, Math.PI * 1.5); ctx.stroke();
      ctx.beginPath(); ctx.arc(u * .55, -u * .45, u * .22, -Math.PI * .5, Math.PI * .5); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(0, u * .2); ctx.lineTo(0, u * .55); ctx.moveTo(-u * .38, u * .72); ctx.lineTo(u * .38, u * .72); ctx.stroke(); break;
    case 'chart':
      ctx.beginPath(); ctx.moveTo(-u * .8, -u * .8); ctx.lineTo(-u * .8, u * .75); ctx.lineTo(u * .85, u * .75); ctx.stroke();
      [[-.45, .3], [-.05, -.15], [.35, -.55]].forEach(([bx, by]) => { rr(ctx, bx * u, by * u, u * .28, (.6 - by) * u, 4); ctx.fill(); }); break;
    case 'qr':
      for (const [qx, qy] of [[-1, -1], [1, -1], [-1, 1]]) { ctx.strokeRect(qx * u * .55 - u * .3, qy * u * .55 - u * .3, u * .6, u * .6); ctx.fillRect(qx * u * .55 - u * .12, qy * u * .55 - u * .12, u * .24, u * .24); }
      for (let i = 0; i < 9; i++) if (rnd(i + 3) > .4) ctx.fillRect(u * .2 + (i % 3) * u * .25, u * .2 + Math.floor(i / 3) * u * .25, u * .18, u * .18); break;
    case 'phone':
      rr(ctx, -u * .45, -u * .85, u * .9, u * 1.7, u * .18); ctx.stroke(); ctx.beginPath(); ctx.moveTo(-u * .12, u * .62); ctx.lineTo(u * .12, u * .62); ctx.stroke(); break;
    case 'shop':
      ctx.beginPath(); ctx.moveTo(-u * .85, -u * .35); ctx.lineTo(-u * .7, -u * .8); ctx.lineTo(u * .7, -u * .8); ctx.lineTo(u * .85, -u * .35); ctx.closePath(); ctx.stroke();
      ctx.strokeRect(-u * .72, -u * .35, u * 1.44, u * 1.1); ctx.strokeRect(-u * .2, u * .2, u * .4, u * .55); break;
    case 'user':
      circle(ctx, 0, -u * .35, u * .35, null, col, ctx.lineWidth);
      ctx.beginPath(); ctx.arc(0, u * .85, u * .75, Math.PI * 1.15, Math.PI * 1.85); ctx.stroke(); break;
    case 'users':
      circle(ctx, -u * .3, -u * .3, u * .28, null, col, ctx.lineWidth); circle(ctx, u * .38, -u * .22, u * .24, null, col, ctx.lineWidth);
      ctx.beginPath(); ctx.arc(-u * .3, u * .75, u * .62, Math.PI * 1.15, Math.PI * 1.85); ctx.stroke();
      ctx.beginPath(); ctx.arc(u * .42, u * .7, u * .5, Math.PI * 1.25, Math.PI * 1.85); ctx.stroke(); break;
    case 'db':
      ctx.beginPath(); ctx.ellipse(0, -u * .55, u * .7, u * .22, 0, 0, Math.PI * 2); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-u * .7, -u * .55); ctx.lineTo(-u * .7, u * .55); ctx.ellipse(0, u * .55, u * .7, u * .22, 0, Math.PI, 0, true); ctx.lineTo(u * .7, -u * .55); ctx.stroke();
      ctx.beginPath(); ctx.ellipse(0, 0, u * .7, u * .22, 0, 0, Math.PI); ctx.stroke(); break;
    case 'heart':
      ctx.beginPath(); ctx.moveTo(0, u * .7); ctx.bezierCurveTo(-u * 1.1, -u * .05, -u * .55, -u * .9, 0, -u * .35);
      ctx.bezierCurveTo(u * .55, -u * .9, u * 1.1, -u * .05, 0, u * .7); ctx.fill(); break;
    case 'gear':
      ctx.beginPath(); for (let i = 0; i < 16; i++) { const a = i / 16 * Math.PI * 2, r = i % 2 ? u * .62 : u * .82; ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r); } ctx.closePath(); ctx.stroke();
      circle(ctx, 0, 0, u * .25, null, col, ctx.lineWidth); break;
    case 'rocket':
      ctx.beginPath(); ctx.moveTo(0, -u * .9); ctx.quadraticCurveTo(u * .5, -u * .4, u * .32, u * .4); ctx.lineTo(-u * .32, u * .4); ctx.quadraticCurveTo(-u * .5, -u * .4, 0, -u * .9); ctx.stroke();
      circle(ctx, 0, -u * .25, u * .14, null, col, ctx.lineWidth);
      ctx.beginPath(); ctx.moveTo(-u * .32, u * .1); ctx.lineTo(-u * .62, u * .5); ctx.lineTo(-u * .3, u * .45); ctx.moveTo(u * .32, u * .1); ctx.lineTo(u * .62, u * .5); ctx.lineTo(u * .3, u * .45); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-u * .15, u * .55); ctx.lineTo(0, u * .9); ctx.lineTo(u * .15, u * .55); ctx.stroke(); break;
    case 'doc':
      ctx.beginPath(); ctx.moveTo(-u * .6, -u * .85); ctx.lineTo(u * .25, -u * .85); ctx.lineTo(u * .6, -u * .5); ctx.lineTo(u * .6, u * .85); ctx.lineTo(-u * .6, u * .85); ctx.closePath(); ctx.stroke();
      for (let i = 0; i < 3; i++) { ctx.beginPath(); ctx.moveTo(-u * .3, -u * .2 + i * u * .32); ctx.lineTo(u * .3, -u * .2 + i * u * .32); ctx.stroke(); } break;
    case 'target':
      circle(ctx, 0, 0, u * .8, null, col, ctx.lineWidth); circle(ctx, 0, 0, u * .5, null, col, ctx.lineWidth); circle(ctx, 0, 0, u * .18, col); break;
    case 'coin':
      circle(ctx, 0, 0, u * .85, C.amber); circle(ctx, 0, 0, u * .62, null, '#FFD27A', u * .1);
      ctx.fillStyle = '#7A4A00'; ctx.font = `800 ${u * .9}px ${FD}`; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText('P', 0, u * .05); break;
    case 'scan':
      ctx.beginPath();
      for (const [sx, sy] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) { ctx.moveTo(sx * u * .8, sy * u * .35); ctx.lineTo(sx * u * .8, sy * u * .8); ctx.lineTo(sx * u * .35, sy * u * .8); }
      ctx.stroke(); ctx.beginPath(); ctx.moveTo(-u * .6, 0); ctx.lineTo(u * .6, 0); ctx.stroke(); break;
    case 'shield':
      ctx.beginPath(); ctx.moveTo(0, -u * .85); ctx.lineTo(u * .7, -u * .55); ctx.quadraticCurveTo(u * .7, u * .5, 0, u * .88); ctx.quadraticCurveTo(-u * .7, u * .5, -u * .7, -u * .55); ctx.closePath(); ctx.stroke(); break;
    case 'live':
      circle(ctx, 0, 0, u * .22, col);
      ctx.beginPath(); ctx.arc(0, 0, u * .5, -.8, .8); ctx.stroke(); ctx.beginPath(); ctx.arc(0, 0, u * .5, Math.PI - .8, Math.PI + .8); ctx.stroke();
      ctx.beginPath(); ctx.arc(0, 0, u * .8, -.7, .7); ctx.stroke(); ctx.beginPath(); ctx.arc(0, 0, u * .8, Math.PI - .7, Math.PI + .7); ctx.stroke(); break;
    case 'down':
      ctx.beginPath(); ctx.moveTo(-u * .8, -u * .6); ctx.lineTo(-u * .2, 0); ctx.lineTo(u * .1, -u * .3); ctx.lineTo(u * .75, u * .5); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(u * .35, u * .55); ctx.lineTo(u * .8, u * .55); ctx.lineTo(u * .8, u * .1); ctx.stroke(); break;
    case 'up':
      ctx.beginPath(); ctx.moveTo(-u * .8, u * .6); ctx.lineTo(-u * .2, 0); ctx.lineTo(u * .1, u * .3); ctx.lineTo(u * .75, -u * .5); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(u * .35, -u * .55); ctx.lineTo(u * .8, -u * .55); ctx.lineTo(u * .8, -u * .1); ctx.stroke(); break;
    case 'loop':
      ctx.beginPath(); ctx.arc(0, 0, u * .65, -Math.PI * .3, Math.PI * 1.45); ctx.stroke();
      { const a = Math.PI * 1.45; const ex = Math.cos(a) * u * .65, ey = Math.sin(a) * u * .65;
        ctx.beginPath(); ctx.moveTo(ex + u * .3, ey - u * .05); ctx.lineTo(ex, ey); ctx.lineTo(ex + u * .05, ey + u * .32); ctx.stroke(); } break;
    case 'ticket':
      ctx.beginPath(); ctx.moveTo(-u * .85, -u * .45); ctx.lineTo(u * .85, -u * .45); ctx.lineTo(u * .85, -u * .15); ctx.arc(u * .85, 0, u * .15, -Math.PI / 2, Math.PI / 2, true);
      ctx.lineTo(u * .85, u * .45); ctx.lineTo(-u * .85, u * .45); ctx.lineTo(-u * .85, u * .15); ctx.arc(-u * .85, 0, u * .15, Math.PI / 2, -Math.PI / 2, true); ctx.closePath(); ctx.stroke(); break;
    case 'board':
      ctx.strokeRect(-u * .85, -u * .6, u * 1.7, u * 1.0); ctx.beginPath(); ctx.moveTo(-u * .3, u * .4); ctx.lineTo(-u * .45, u * .85); ctx.moveTo(u * .3, u * .4); ctx.lineTo(u * .45, u * .85); ctx.stroke(); break;
  }
  ctx.restore();
}

// ---------- people ----------
function person(ctx, x, y, s, shirt, o = {}) {
  ctx.save(); ctx.translate(x, y); ctx.scale(s, s);
  const skin = o.skin || C.skin;
  // legs
  ctx.strokeStyle = o.pants || '#2B2950'; ctx.lineWidth = 16; ctx.lineCap = 'round';
  ctx.beginPath(); ctx.moveTo(-12, 40); ctx.lineTo(-14, 100); ctx.moveTo(12, 40); ctx.lineTo(14, 100); ctx.stroke();
  // body
  ctx.fillStyle = shirt; rr(ctx, -34, -30, 68, 80, 26); ctx.fill();
  // arms
  ctx.strokeStyle = shirt; ctx.lineWidth = 15;
  const arm = (side, kind) => {
    ctx.beginPath(); ctx.moveTo(side * 28, -18);
    if (kind === 'up') { ctx.lineTo(side * 52, -50); ctx.lineTo(side * 58, -88); }
    else if (kind === 'phone') { ctx.lineTo(side * 40, 14); ctx.lineTo(side * 12, -4); }
    else if (kind === 'point') { ctx.lineTo(side * 62, -26); ctx.lineTo(side * 96, -34); }
    else if (kind === 'hold') { ctx.lineTo(side * 44, 12); ctx.lineTo(side * 64, 6); }
    else { ctx.lineTo(side * 40, 14); ctx.lineTo(side * 42, 44); }
    ctx.stroke();
  };
  arm(-1, o.left || 'down'); arm(1, o.right || 'down');
  // head
  circle(ctx, 0, -62, 30, skin);
  ctx.fillStyle = o.hairC || C.hair; ctx.beginPath(); ctx.arc(0, -66, 31, Math.PI * 1.05, Math.PI * 1.95); ctx.closePath(); ctx.fill();
  if (o.long) { rr(ctx, -32, -72, 12, 46, 6); ctx.fill(); rr(ctx, 20, -72, 12, 46, 6); ctx.fill(); }
  // face
  ctx.fillStyle = '#1A1220';
  if (o.sad) { ctx.fillRect(-12, -62, 7, 3); ctx.fillRect(6, -62, 7, 3); ctx.strokeStyle = '#1A1220'; ctx.lineWidth = 3; ctx.beginPath(); ctx.arc(0, -40, 9, Math.PI * 1.2, Math.PI * 1.8); ctx.stroke(); }
  else { circle(ctx, -10, -60, 3.5, '#1A1220'); circle(ctx, 10, -60, 3.5, '#1A1220'); ctx.strokeStyle = '#1A1220'; ctx.lineWidth = 3; ctx.beginPath(); ctx.arc(0, -54, 9, .25 * Math.PI, .75 * Math.PI); ctx.stroke(); }
  if (o.badge) { circle(ctx, 16, -6, 7, o.badge); }
  ctx.restore();
}

// ---------- devices ----------
function phone(ctx, x, y, w, h, drawScreen, o = {}) {
  ctx.save(); ctx.translate(x, y); if (o.rot) ctx.rotate(o.rot);
  ctx.shadowColor = 'rgba(0,0,0,.5)'; ctx.shadowBlur = 40; ctx.shadowOffsetY = 20;
  fillRR(ctx, -w / 2, -h / 2, w, h, w * .14, '#0B0A16');
  ctx.shadowColor = 'transparent';
  fillRR(ctx, -w / 2, -h / 2, w, h, w * .14, null, '#3A3766', 3);
  const m = w * .045; const sx = -w / 2 + m, sy = -h / 2 + m, sw = w - 2 * m, sh = h - 2 * m;
  ctx.save(); rr(ctx, sx, sy, sw, sh, w * .11); ctx.clip();
  ctx.fillStyle = o.screen || '#F4F3FF'; ctx.fillRect(sx, sy, sw, sh);
  ctx.translate(sx, sy); drawScreen && drawScreen(sw, sh);
  ctx.restore();
  fillRR(ctx, -w * .14, -h / 2 + m + 8, w * .28, w * .07, w * .035, '#0B0A16');
  ctx.restore();
}
function card(ctx, x, y, w, h, o = {}) {
  ctx.save();
  if (o.shadow !== false) { ctx.shadowColor = 'rgba(0,0,0,.45)'; ctx.shadowBlur = 30; ctx.shadowOffsetY = 12; }
  fillRR(ctx, x, y, w, h, o.r || 22, o.fill || C.card);
  ctx.shadowColor = 'transparent';
  fillRR(ctx, x, y, w, h, o.r || 22, null, o.stroke || hexA('#FFFFFF', .08), o.lw || 2);
  ctx.restore();
}
function chip(ctx, s, x, y, col, o = {}) {
  const size = o.size || 26, padX = size * .8, h = size * 1.9;
  const w = tw(ctx, s, size, o.w || 600) + padX * 2 + (o.icon ? size * 1.3 : 0);
  const X = o.a === 'center' ? x - w / 2 : x;
  fillRR(ctx, X, y - h / 2, w, h, h / 2, o.fill || hexA(col, .16), hexA(col, .55), 2);
  if (o.icon) icon(ctx, o.icon, X + padX + size * .45, y, size * 1.05, col);
  txt(ctx, s, X + padX + (o.icon ? size * 1.3 : 0), y + size * .36, size, { c: o.tc || C.white, w: o.w || 600 });
  return w;
}

// ---------- brand marks ----------
let LOGO = null;
function softLogo(ctx, x, y, w, a = 1) {
  if (!LOGO) return; const h = w * LOGO.height / LOGO.width;
  ctx.save(); ctx.globalAlpha *= a; ctx.drawImage(LOGO, x - w / 2, y - h / 2, w, h); ctx.restore();
}

// ---------- background ----------
let GRID = null;
function makeGrid() {
  GRID = document.createElement('canvas'); GRID.width = W; GRID.height = H;
  const g = GRID.getContext('2d');
  g.fillStyle = 'rgba(255,255,255,0.05)';
  for (let x = 24; x < W; x += 48) for (let y = 24; y < H; y += 48) g.fillRect(x - 1.5, y - 1.5, 3, 3);
  const v = g.createRadialGradient(W / 2, H / 2, H * .35, W / 2, H / 2, W * .75);
  v.addColorStop(0, 'rgba(0,0,0,0)'); v.addColorStop(1, 'rgba(0,0,0,0.55)');
  g.fillStyle = v; g.fillRect(0, 0, W, H);
}
function bg(ctx, o = {}) {
  const g = ctx.createLinearGradient(0, 0, W, H); g.addColorStop(0, o.c0 || '#0F0E1C'); g.addColorStop(1, o.c1 || '#1A1738');
  ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
  const blobs = o.blobs || [[C.brand, .22], [C.teal, .12], [C.violet, .14]];
  blobs.forEach(([col, a], i) => {
    const x = W * (.2 + .3 * i) + Math.sin(G * .17 + i * 2.1) * 260, y = H * (.3 + .25 * (i % 2)) + Math.cos(G * .13 + i) * 180;
    const r = 520 + 80 * Math.sin(G * .2 + i);
    const rg = ctx.createRadialGradient(x, y, 0, x, y, r); rg.addColorStop(0, hexA(col, a)); rg.addColorStop(1, hexA(col, 0));
    ctx.fillStyle = rg; ctx.fillRect(0, 0, W, H);
  });
  ctx.drawImage(GRID, 0, 0);
  // floating motes
  for (let i = 0; i < 26; i++) {
    const x = (rnd(i) * W + G * (8 + rnd(i + 9) * 18)) % W, y = (rnd(i + 50) * H - G * (6 + rnd(i + 3) * 10) % H + H) % H;
    circle(ctx, x, y, 1.5 + rnd(i + 7) * 2.5, hexA(i % 3 ? C.violet : C.teal, .25 + .2 * rnd(i + 2)));
  }
}

// ---------- shared HUD pieces ----------
function sceneTag(ctx, s, x, y, col, a = 1) {
  ctx.save(); ctx.globalAlpha *= a;
  fillRR(ctx, x, y - 20, tw(ctx, s, 20, 700, FB, 4) + 40, 40, 20, hexA(col, .18), hexA(col, .6), 2);
  txt(ctx, s, x + 20, y + 7, 20, { w: 700, c: col, ls: 4 }); ctx.restore();
}
function headline(ctx, lines, x, y, size, t0, lt, o = {}) {
  lines.forEach((ln, i) => {
    const p = P(lt, t0 + i * .12, t0 + i * .12 + .6);
    if (p <= 0) return;
    ctx.save(); ctx.beginPath(); ctx.rect(o.a === 'center' ? 0 : x - 20, y + i * size * 1.12 - size * 1.05, o.a === 'center' ? W : Math.min(1400, W - x + 20), size * 1.35); ctx.clip();
    const parts = Array.isArray(ln) ? ln : [[ln, o.c || C.white]];
    let cx = o.a === 'center' ? x - parts.reduce((s, [t]) => s + tw(ctx, t, size, 700, FD), 0) / 2 : x;
    parts.forEach(([t, c]) => { txt(ctx, t, cx, y + i * size * 1.12 + (1 - p) * size * 1.1, size, { f: FD, w: 700, c }); cx += tw(ctx, t, size, 700, FD); });
    ctx.restore();
  });
}
// Largest size (up to `size`) at which every headline line fits in maxW. lines: strings or [[text, colour], ...]
function fitSize(ctx, lines, size, maxW, w = 700, f = FD) {
  const widest = Math.max(1, ...lines.map(l => (Array.isArray(l) ? l : [[l]]).reduce((s, [t]) => s + tw(ctx, t, size, w, f), 0)));
  return widest > maxW ? Math.floor(size * maxW / widest) : size;
}
