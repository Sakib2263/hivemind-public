// Starter scenes — data-driven building blocks. Configure each scene from cuts.json via its options
// (sc.opt). Copy a block and customise it when a video needs a bespoke illustration.
// Scene contract: SC.<id> = { draw(ctx, lt, d, sc), cues(d, sc) -> [[localTime, sfxName, gain], ...] }
//   lt = seconds into the scene, d = scene duration, sc.caps[i].t0 = when VO line i starts (for sync).
// A scene entry in cuts.json picks its block with "type" (defaults to its id).

const TRANS = {};               // e.g. { 'hook>reveal': 'flash', 'points>endcard': 'zoom' }
const TRANS_DEFAULT = 'slide';  // slide | fade | zoom | iris | wipe | flash | cut
const NO_CAPS = ['endcard'];

// Brand: override palette here (keys used across the engine)
Object.assign(C, { brand: '#5B4FE8', teal: '#00C9A7', amber: '#F5A623', violet: '#8B7FFF' });

const SC = {};
const ct = (sc, i, fb) => (sc.caps && sc.caps[i]) ? sc.caps[i].t0 : fb;
const at = (sc, d, i, n) => ct(sc, i, .5 + i * (d - 1.2) / Math.max(1, n)); // sync item i to VO line i, else spread

// Look up the block for a scene: "type" option or the id itself
const _draw = (ctx, lt, d, sc) => (BLOCKS[sc.opt.type || sc.id] || BLOCKS.title).draw(ctx, lt, d, sc);
const _cues = (d, sc) => ((BLOCKS[sc.opt.type || sc.id] || BLOCKS.title).cues || (() => []))(d, sc);
function onInit() { TL.scenes.forEach(s => { if (!SC[s.id]) SC[s.id] = { draw: _draw, cues: _cues }; }); }

const BLOCKS = {
  // Logo sting. opt: { text: "PRESENTS" }
  intro: {
    draw(ctx, lt, d, sc) {
      bg(ctx);
      const p = P(lt, .3, 1.4), lw = Math.min(760, W * .72);
      if (LOGO) softLogo(ctx, W / 2, vy(500), lw, p); else txt(ctx, sc.opt.brand || 'Your Brand', W / 2, vy(520), Math.min(90, W / 12), { f: FD, w: 700, a: 'center', alpha: p });
      txt(ctx, sc.opt.text || 'PRESENTS', W / 2, vy(640), 26, { a: 'center', c: C.muted, ls: 12, alpha: P(lt, 1.2, 1.9) });
      ctx.fillStyle = `rgba(15,14,28,${P(lt, d - .5, d, lin) * .6})`; ctx.fillRect(0, 0, W, H);
    },
    cues: d => [[0, 'riser', .5], [.4, 'shimmer', .6], [1.2, 'chime', .5]]
  },
  // Big statement. opt: { kicker, title: ["line", [["two-tone ", "#fff"], ["words", "teal"]]], sub, size, tone: "dark"|"grey" }
  title: {
    draw(ctx, lt, d, sc) {
      const o = sc.opt; bg(ctx);
      const lines = (o.title || [sc.id]).map(l => Array.isArray(l) ? l.map(([t, c]) => [t, C[c] || c]) : l);
      const size = fitSize(ctx, lines, o.size || (VERT ? 96 : 84), W - (VERT ? 120 : 240)), y = vy(500) - (VERT ? (lines.length - 1) * size * .56 : 0);
      if (o.kicker) sceneTag(ctx, o.kicker, W / 2 - tw(ctx, o.kicker, 20, 700, FB, 4) / 2 - 20, y - size - 70, C.teal, P(lt, .1, .5));
      headline(ctx, lines, W / 2, y, size, .2, lt, { a: 'center' });
      const ss = VERT ? 40 : 34;
      if (o.sub) wrap(ctx, o.sub, Math.min(1200, W - 160), ss, 500).forEach((l, i) => txt(ctx, l, W / 2, y + lines.length * size * 1.13 + 20 + i * ss * 1.35, ss, { a: 'center', c: C.muted, w: 500, alpha: P(lt, .7, 1.2) }));
      if (o.tone === 'grey') { ctx.save(); ctx.globalCompositeOperation = 'saturation'; ctx.globalAlpha = P(lt, 0, 1.5); ctx.fillStyle = '#808080'; ctx.fillRect(0, 0, W, H); ctx.restore(); }
    },
    cues: () => [[.2, 'whoosh', .35], [.5, 'pop', .3]]
  },
  // Cards that pop in, one per VO line. opt: { heading, items: [["Label", "icon", "teal"], ...], cols: 3 }
  // Portrait: one column of wide cards (icon left, label right).
  points: {
    draw(ctx, lt, d, sc) {
      const o = sc.opt, items = o.items || []; bg(ctx);
      const n = items.length, gap = 40;
      if (VERT) {
        const cw = W - 160, chh = 210, top = vy(560) - (n * chh + (n - 1) * gap) / 2;
        if (o.heading) headline(ctx, [o.heading], W / 2, top - 110, fitSize(ctx, [o.heading], 64, W - 120), .1, lt, { a: 'center' });
        items.forEach(([s, ic, col], j) => {
          const c = C[col] || col || C.teal, t = at(sc, d, j + (o.offset || 0), n), p = P(lt, t, t + .45, eob); if (p <= 0) return;
          withT(ctx, W / 2, top + j * (chh + gap) + chh / 2, p, 0, () => {
            card(ctx, -cw / 2, -chh / 2, cw, chh, { stroke: hexA(c, .55) });
            circle(ctx, -cw / 2 + 110, 0, 62, hexA(c, .2)); icon(ctx, ic || 'target', -cw / 2 + 110, 0, 64, c);
            const ls = wrap(ctx, s, cw - 260, 44, 700, FD);
            ls.forEach((l, i) => txt(ctx, l, -cw / 2 + 210, 15 + (i - (ls.length - 1) / 2) * 54, 44, { f: FD, w: 700 }));
          });
        });
        return;
      }
      if (o.heading) headline(ctx, [o.heading], W / 2, vy(190), 60, .1, lt, { a: 'center' });
      const cols = o.cols || Math.min(3, n), rows = Math.ceil(n / cols);
      const cw = Math.min(520, (Math.min(1680, W - 120) - (cols - 1) * gap) / cols), chh = rows > 1 ? 230 : 320;
      items.forEach(([s, ic, col], j) => {
        const c = C[col] || col || C.teal, t = at(sc, d, j + (o.offset || 0), n);
        const x = W / 2 - (cols * cw + (cols - 1) * gap) / 2 + (j % cols) * (cw + gap) + cw / 2;
        const y = vy(560) - (rows - 1) * (chh + gap) / 2 + Math.floor(j / cols) * (chh + gap);
        const p = P(lt, t, t + .45, eob); if (p <= 0) return;
        withT(ctx, x, y, p, 0, () => {
          card(ctx, -cw / 2, -chh / 2, cw, chh, { stroke: hexA(c, .55) });
          circle(ctx, 0, -chh / 2 + 85, 52, hexA(c, .2)); icon(ctx, ic || 'target', 0, -chh / 2 + 85, 54, c);
          wrap(ctx, s, cw - 50, 30, 700, FD).forEach((l, i) => txt(ctx, l, 0, -chh / 2 + 185 + i * 38, 30, { a: 'center', f: FD, w: 700 }));
        });
      });
    },
    cues: (d, sc) => [[.05, 'whoosh', .35], ...(sc.opt.items || []).map((_, j) => [at(sc, d, j + (sc.opt.offset || 0), sc.opt.items.length), 'pop', .4])]
  },
  // Numbered steps on a line. opt: { heading, steps: [["Title", "icon", "sub"], ...] }
  // Landscape: left to right. Portrait: top to bottom, text to the right of each node.
  steps: {
    draw(ctx, lt, d, sc) {
      const o = sc.opt, S = o.steps || [], n = S.length; bg(ctx);
      const T = S.map((_, i) => at(sc, d, i + (o.offset || 0), n));
      let k = 0; T.forEach((t, i) => { if (i && lt > t) k = i - 1 + P(lt, t, t + .5); });
      let pts, hy;
      if (VERT) {
        const sp = Math.min(330, 1100 / Math.max(1, n - 1)), x = W / 2 - 300;
        pts = S.map((_, i) => [x, vy(560) + (i - (n - 1) / 2) * sp]); hy = pts[0][1] - 230;
      } else {
        pts = S.map((_, i) => [W / 2 + (i - (n - 1) / 2) * Math.min(480, 1500 / Math.max(1, n - 1), (W - 360) / Math.max(1, n - 1)), vy(540)]); hy = vy(220);
      }
      if (o.heading) headline(ctx, [o.heading], W / 2, hy, fitSize(ctx, [o.heading], 60, W - 120), .1, lt, { a: 'center' });
      const [a0, a1] = [pts[0], pts[n - 1]], f = n > 1 ? k / (n - 1) : 0;
      ctx.save(); ctx.strokeStyle = 'rgba(255,255,255,.1)'; ctx.lineWidth = 6; ctx.beginPath(); ctx.moveTo(...a0); ctx.lineTo(...a1); ctx.stroke();
      ctx.strokeStyle = C.teal; ctx.beginPath(); ctx.moveTo(...a0); ctx.lineTo(lerp(a0[0], a1[0], f), lerp(a0[1], a1[1], f)); ctx.stroke(); ctx.restore();
      S.forEach(([s, ic, sub], i) => {
        const p = P(lt, T[i] - .1, T[i] + .4, eob); if (p <= 0) return; const col = [C.violet, C.teal, C.amber][i % 3];
        withT(ctx, pts[i][0], pts[i][1], p, 0, () => {
          glowDot(ctx, 0, 0, 150, col, .5); circle(ctx, 0, 0, 86, C.card2, col, 4); icon(ctx, ic || 'target', 0, 0, 80, col);
          circle(ctx, 62, -62, 24, col); txt(ctx, '' + (i + 1), 62, -52, 26, { a: 'center', f: FD, w: 700, c: C.dark });
          if (VERT) {
            txt(ctx, s, 130, sub ? -4 : 14, 46, { f: FD, w: 700 }); if (sub) txt(ctx, sub, 130, 44, 32, { c: C.muted, w: 500 });
          } else {
            txt(ctx, s, 0, 150, 38, { a: 'center', f: FD, w: 700 }); if (sub) txt(ctx, sub, 0, 195, 26, { a: 'center', c: C.muted, w: 500 });
          }
        });
      });
    },
    cues: (d, sc) => [[.05, 'whoosh', .35], ...(sc.opt.steps || []).map((_, i) => [at(sc, d, i + (sc.opt.offset || 0), sc.opt.steps.length) - .1, 'pop', .45])]
  },
  // Big number / stat. opt: { value: 87, suffix: "%", label: "..." }
  stat: {
    draw(ctx, lt, d, sc) {
      const o = sc.opt; bg(ctx); const p = P(lt, .3, 1.8, eio);
      const s = (o.prefix || '') + Math.round((o.value || 0) * p) + (o.suffix || ''), full = (o.prefix || '') + (o.value || 0) + (o.suffix || '');
      const size = fitSize(ctx, [full], VERT ? 260 : 220, W - 140);
      glowDot(ctx, W / 2, vy(470), Math.min(380, W * .4), C.brand, .5 * p);
      txt(ctx, s, W / 2, vy(540), size, { a: 'center', f: FD, w: 700, c: C[o.color] || C.teal });
      if (o.label) wrap(ctx, o.label, W - 160, VERT ? 46 : 40, 600).forEach((l, i) => txt(ctx, l, W / 2, vy(650) + (VERT ? 40 : 0) + i * 58, VERT ? 46 : 40, { a: 'center', w: 600, alpha: P(lt, 1, 1.5) }));
    },
    cues: () => [[.3, 'tickroll', .3], [1.8, 'success', .45]]
  },
  // Closing card. opt: { tagline: ["line 1", "line 2"], cta: "Book a demo", contact: "www.x.com · hi@x.com" }
  endcard: {
    draw(ctx, lt, d, sc) {
      const o = sc.opt, tg = o.tagline || []; bg(ctx, { blobs: [[C.brand, .3], [C.teal, .16], [C.violet, .2]] });
      if (LOGO) softLogo(ctx, W / 2, vy(300), Math.min(560, W * .6), P(lt, 0, 1)); else txt(ctx, o.brand || '', W / 2, vy(330), Math.min(90, W / 12), { a: 'center', f: FD, w: 700, alpha: P(lt, 0, 1) });
      const ts = fitSize(ctx, tg.length ? tg : [''], VERT ? 72 : 64, W - 140), y0 = vy(520), lh = ts * 1.4;
      tg.forEach((l, i) => { const t = ct(sc, i + (o.offset || 0), .5 + i * .8), a = P(lt, t, t + .5, eob);
        if (a > 0) withT(ctx, W / 2, y0 + i * lh, lerp(.9, 1, a), 0, () => txt(ctx, l, 0, 0, ts, { a: 'center', f: FD, w: 700, c: i ? C.teal : C.white }), a); });
      const t2 = ct(sc, tg.length - 1 + (o.offset || 0), 1.3) + .6, c = P(lt, t2, t2 + .5, eob);
      if (o.cta && c > 0) withT(ctx, W / 2, y0 + tg.length * lh + 40, c * (1 + .03 * Math.sin(lt * 5)), 0, () => {
        const w = tw(ctx, o.cta, 32, 700, FD) + 100; fillRR(ctx, -w / 2, -40, w, 80, 40, C.amber); txt(ctx, o.cta, 0, 12, 32, { a: 'center', f: FD, w: 700, c: C.dark }); });
      if (o.contact) txt(ctx, o.contact, W / 2, VERT ? Math.min(vy(960), H - 460) : vy(960), 28, { a: 'center', w: 600, c: C.surface, alpha: P(lt, t2 + .4, t2 + .9) });
      ctx.fillStyle = `rgba(0,0,0,${P(lt, d - .9, d, lin)})`; ctx.fillRect(0, 0, W, H);
    },
    cues: (d, sc) => [[0, 'impact', .7], [.2, 'shimmer', .6], [ct(sc, (sc.opt.tagline || []).length - 1, 1.3) + .6, 'pop', .45]]
  }
};
