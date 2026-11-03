// Android launcher icons from one square PNG (Hivemind android-build.sh, run inside the Capacitor folder).
//   node make-android-icon.cjs make  <icon.png> <android/app/src/main/res>
//     legacy ic_launcher + ic_launcher_round (48 dp), adaptive foreground (108 dp, logo fills the visible
//     74 dp), background color from the logo's edge, mipmap-anydpi-v26 XMLs. Replaces @capacitor/assets.
//   node make-android-icon.cjs check <folder of PNGs from the APK> <made foreground png>
//     PASS when one APK image matches the made foreground (exit 1 otherwise).
// Uses sharp from the Capacitor project's node_modules (installed with @capacitor/assets).
const fs = require('fs'), path = require('path');
const sharp = require(require.resolve('sharp', { paths: [process.cwd(), __dirname] }));
const D = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
const [, , mode, a, b] = process.argv;

async function edgeColor(src) {
  const { data } = await sharp(src).resize(64, 64).removeAlpha().raw().toBuffer({ resolveWithObject: true });
  let r = 0, g = 0, bl = 0, n = 0;
  for (let y = 0; y < 64; y++) for (let x = 0; x < 64; x++) {
    if (x > 1 && x < 62 && y > 1 && y < 62) continue;
    const i = (y * 64 + x) * 3; r += data[i]; g += data[i + 1]; bl += data[i + 2]; n++;
  }
  const h = v => Math.round(v / n).toString(16).padStart(2, '0');
  return '#' + h(r) + h(g) + h(bl);
}
const mask = (s, round) => Buffer.from(`<svg width="${s}" height="${s}"><rect width="${s}" height="${s}" rx="${round ? s / 2 : s * 0.18}" fill="#fff"/></svg>`);

async function make(src, res) {
  const meta = await sharp(src).metadata();
  if (meta.width !== meta.height) throw new Error('icon must be square, got ' + meta.width + 'x' + meta.height);
  const bg = await edgeColor(src);
  for (const [k, f] of Object.entries(D)) {
    const dir = path.join(res, 'mipmap-' + k); fs.mkdirSync(dir, { recursive: true });
    const L = Math.round(48 * f), F = Math.round(108 * f), V = Math.round(74 * f);
    const base = await sharp(src).resize(L, L).png().toBuffer();
    await sharp(base).composite([{ input: mask(L, false), blend: 'dest-in' }]).png().toFile(path.join(dir, 'ic_launcher.png'));
    await sharp(base).composite([{ input: mask(L, true), blend: 'dest-in' }]).png().toFile(path.join(dir, 'ic_launcher_round.png'));
    const logo = await sharp(src).resize(V, V).png().toBuffer(), o = Math.round((F - V) / 2);
    await sharp({ create: { width: F, height: F, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } } })
      .composite([{ input: logo, left: o, top: o }]).png().toFile(path.join(dir, 'ic_launcher_foreground.png'));
  }
  const any = path.join(res, 'mipmap-anydpi-v26'); fs.mkdirSync(any, { recursive: true });
  const xml = '<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n' +
    '    <background android:drawable="@color/hm_icon_bg"/>\n    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n</adaptive-icon>\n';
  fs.writeFileSync(path.join(any, 'ic_launcher.xml'), xml);
  fs.writeFileSync(path.join(any, 'ic_launcher_round.xml'), xml);
  fs.mkdirSync(path.join(res, 'values'), { recursive: true });
  fs.writeFileSync(path.join(res, 'values', 'hm_icon.xml'),
    `<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="hm_icon_bg">${bg}</color>\n</resources>\n`);
  console.log('icon: made 5 densities + adaptive icon, background ' + bg);
}

async function px(file) { return sharp(file).resize(48, 48).ensureAlpha().raw().toBuffer(); }
async function check(dir, made) {
  const want = await px(made); let best = 1e9;
  for (const f of fs.readdirSync(dir)) {
    try { const got = await px(path.join(dir, f)); let d = 0;
      for (let i = 0; i < want.length; i++) d += Math.abs(want[i] - got[i]);
      best = Math.min(best, d / want.length); } catch (e) {}
  }
  if (best < 8) { console.log('ICON CHECK: PASS (adaptive icon in the APK matches the app icon, diff ' + best.toFixed(1) + ')'); return; }
  console.log('ICON CHECK: FAIL (no adaptive icon in the APK matches the app icon' + (best < 1e9 ? ', best diff ' + best.toFixed(1) : '') + ')');
  process.exit(1);
}

(mode === 'make' ? make(a, b) : mode === 'check' ? check(a, b) : Promise.reject(new Error('usage: make|check')))
  .catch(e => { console.error('icon: ' + e.message); process.exit(1); });
