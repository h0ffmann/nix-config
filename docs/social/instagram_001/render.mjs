// Renders the five 1080x1350 slides of the first Instagram post next to this file.
//   node render.mjs            (Playwright on the module path; CHROMIUM=<path> to pick a binary)
// The logo and the drawings are read from the repo, so a change to them shows on the next render.
import { chromium } from 'playwright';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { readFileSync } from 'node:fs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../../..');
// The files carry their own light/dark <style>; the slides set one palette for all of them.
const svg = (p) => readFileSync(path.join(root, p), 'utf8').replace(/<style>[\s\S]*?<\/style>/, '');
const logo = svg('docs/media/logo.svg');
const draw = (n, w) => svg(`site/static/drawings/${n}.svg`)
  .replace('width="360" height="240"', `width="${w}" height="${Math.round(w * 2 / 3)}"`);
const cves = JSON.parse(readFileSync(path.join(here, 'cves.json'), 'utf8'));
const C = { cream: '#F3EDE2', ink: '#1d1b19', blue: '#5277C3', rose: '#E8A87C', accent: '#d9480f', muted: '#6b645b' };


// Cumulative CVE advisories per ecosystem, drawn like a GitHub star-history chart.
function cveChart(w, h) {
  const series = { npm: C.accent, PyPI: C.blue };
  const months = [];
  for (let y = 2018; y <= 2026; y++) for (let m = 1; m <= 12; m++) months.push(`${y}-${String(m).padStart(2, '0')}`);
  const last = Object.values(cves.monthly).flatMap(Object.keys).sort().at(-1);
  const xs = months.filter((m) => m <= last);
  const cum = {};
  for (const [eco, by] of Object.entries(cves.monthly)) {
    let t = Object.entries(by).filter(([k]) => k < xs[0]).reduce((a, [, v]) => a + v, 0);
    cum[eco] = xs.map((m) => (t += by[m] ?? 0));
  }
  const max = Math.ceil(Math.max(...Object.values(cum).flat()) / 1000) * 1000;
  const L = 70, B = 40, X = (i) => L + (i / (xs.length - 1)) * (w - L - 10), Y = (v) => h - B - (v / max) * (h - B - 10);
  let g = '';
  for (let v = 0; v <= max; v += 2000) g += `<line x1="${L}" x2="${w - 10}" y1="${Y(v)}" y2="${Y(v)}" stroke="#d9d1c3" stroke-width="1.5"/><text x="${L - 12}" y="${Y(v) + 7}" text-anchor="end">${v ? `${v / 1000}k` : 0}</text>`;
  for (let y = 2018; y <= 2026; y += 2) { const i = xs.indexOf(`${y}-01`); g += `<text x="${X(i)}" y="${h - 6}" text-anchor="middle">${y}</text>`; }
  for (const [eco, col] of Object.entries(series)) {
    const pts = cum[eco].map((v, i) => `${X(i).toFixed(1)},${Y(v).toFixed(1)}`).join(' ');
    const end = cum[eco].at(-1);
    g += `<polyline points="${pts}" fill="none" stroke="${col}" stroke-width="6" stroke-linejoin="round" stroke-linecap="round"/>`;
    g += `<circle cx="${X(xs.length - 1)}" cy="${Y(end)}" r="9" fill="${col}"/>`;
  }
  return `<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" style="font-family:'DejaVu Sans Mono',monospace;font-size:22px;fill:${C.muted};overflow:visible">${g}</svg>`;
}
const total = (eco, from) => Object.entries(cves.monthly[eco]).filter(([k]) => k >= from).reduce((a, [, v]) => a + v, 0);
const fmt = (n) => n.toLocaleString('en-US');

const css = `
*{margin:0;padding:0;box-sizing:border-box}
body{width:1080px;height:1350px;font-family:Inter,sans-serif;color:${C.ink};background:${C.cream};position:relative;overflow:hidden}
.ink,.l{fill:none;stroke:${C.ink};stroke-linecap:round;stroke-linejoin:round}
.ink{stroke-width:6.5}.l{stroke-width:3.2}.pupil,.d{fill:${C.ink}}
.blue{fill:${C.blue}}.rose{fill:${C.rose}}
.a{fill:none;stroke:${C.accent};stroke-width:3.2;stroke-linecap:round}
.pad{position:absolute;inset:96px 96px 160px}
.mono{font-family:'DejaVu Sans Mono',monospace}
.kicker{font-family:'DejaVu Sans Mono',monospace;font-size:28px;letter-spacing:2px;color:${C.blue}}
h1{font-family:'Inter Display',Inter;font-weight:700;font-size:112px;line-height:1;letter-spacing:-3px}
h2{font-family:'Inter Display',Inter;font-weight:700;font-size:72px;line-height:1.05;letter-spacing:-2px}
p{font-size:36px;line-height:1.35}
.num{font-family:'Inter Display',Inter;font-weight:700;font-size:120px;line-height:1;letter-spacing:-4px;color:${C.blue}}
.src{font-family:'DejaVu Sans Mono',monospace;font-size:20px;line-height:1.4;color:${C.muted};margin-top:10px}
.mark{background:linear-gradient(transparent 62%, ${C.rose} 62%);padding:0 4px}
blockquote{border-left:8px solid ${C.rose};padding:4px 0 4px 28px;font-size:32px;line-height:1.35;font-style:italic}
.foot{position:absolute;left:96px;right:96px;bottom:64px;display:flex;justify-content:space-between;align-items:center;font-family:'DejaVu Sans Mono',monospace;font-size:24px;color:${C.muted}}
.page{color:${C.accent}}
`;
const foot = (n) => `<div class="foot"><span>${logo.replace('width="240" height="240"', 'width="64" height="64"')}</span><span>h0ffmann.github.io/picasso</span><span class="page">${n}/5</span></div>`;

const slides = [
  `<div class="pad">
    <div class="kicker">v0.1.1 · first release on zenodo</div>
    <div style="margin:56px 0 40px;display:flex;justify-content:center">${logo.replace('width="240" height="240"', 'width="500" height="500"')}</div>
    <h1>picasso</h1>
    <p style="margin-top:28px;font-size:44px">A toolchain is a dependency,<br><span class="mark">so pin it like one.</span></p>
    <div class="src" style="margin-top:28px">doi:10.5281/zenodo.23311208</div>
  </div>${foot(1)}`,

  `<div class="pad">
    <div class="kicker">the problem</div>
    <h2 style="margin-top:36px">Python and JavaScript:<br><span class="mark">two cans of worms.</span></h2>
    <div style="display:flex;gap:56px;margin-top:56px">
      <div style="flex:1"><div class="num">4.03%</div>
        <p style="margin-top:16px;font-size:30px">of 1.4M Jupyter notebooks gave their own results again.</p>
        <div class="src">Pimentel et al., MSR 2019</div></div>
      <div style="flex:1"><div class="num">174</div>
        <p style="margin-top:16px;font-size:30px">malicious packages from real attacks, shipped via registries like npm and PyPI.</p>
        <div class="src">Ohm et al., DIMVA 2020</div></div>
    </div>
    <blockquote style="margin-top:64px">“The only historical exception to that rule was JavaScript, and that’s a can of worms that doesn’t fit in this article.”</blockquote>
    <div class="src" style="padding-left:36px">Fabio Akita, akitaonrails.com, 19 Sep 2026</div>
    <div style="margin-top:8px;margin-left:auto;width:360px">${draw('owl', 360)}</div>
  </div>${foot(2)}`,

  `<div class="pad">
    <div class="kicker">the evidence</div>
    <h2 style="margin-top:36px">CVEs in npm and PyPI, <span class="mark">every month, piling up.</span></h2>
    <div style="margin-top:40px;display:flex;gap:40px;font-size:30px">
      <div><span style="color:${C.accent};font-weight:700">● npm</span> ${fmt(total('npm', '0'))}</div>
      <div><span style="color:${C.blue};font-weight:700">● PyPI</span> ${fmt(total('PyPI', '0'))}</div>
    </div>
    <div style="margin-top:28px">${cveChart(888, 470)}</div>
    <p style="margin-top:36px;font-size:30px">${fmt(total('npm', '2026') + total('PyPI', '2026'))} of them published in 2026 alone, more than in 2023, 2024 and 2025 together.</p>
    <div class="src">GitHub Advisory Database (reviewed, with a CVE id), via OSV, ${cves.fetched}</div>
  </div>${foot(3)}`,
  `<div class="pad">
    <div class="kicker">the idea</div>
    <h2 style="margin-top:36px">If the generator is stochastic, <span class="mark">the rest must be deterministic.</span></h2>
    <div style="margin-top:48px"><span class="num" style="font-size:96px">80</span>
      <p style="display:inline;font-size:30px;margin-left:12px">different answers from 1,000 identical LLM requests at temperature 0.</p>
      <div class="src">He / Thinking Machines Lab, 2025</div></div>
    <div style="margin-top:36px"><span class="num" style="font-size:96px">&gt;99%</span>
      <p style="display:inline;font-size:30px;margin-left:12px">of 709,816 nixpkgs packages rebuilt from their recorded inputs.</p>
      <div class="src">Malka, Zacchiroli, Zimmermann, arXiv:2501.15919</div></div>
    <div style="margin-top:24px;margin-left:auto;width:440px">${draw('guitar', 440)}</div>
  </div>${foot(4)}`,
  `<div class="pad">
    <div class="kicker">read · cite · borrow</div>
    <h2 style="margin-top:36px">Same inputs,<br>same factory.</h2>
    <p style="margin-top:28px">The whitepaper on why determinism matters in 2026, and six Nix labs you can pin from your own repo.</p>
    <div class="src">Hoffmann, M. (2026). Same inputs, same factory: why determinism matters in 2026. v1.0.</div>
    <div class="mono" style="margin-top:44px;font-size:32px;line-height:1.7">
      <div><span style="color:${C.blue}">doi</span> 10.5281/zenodo.23311208</div>
      <div><span style="color:${C.blue}">web</span> h0ffmann.github.io/picasso</div>
      <div><span style="color:${C.blue}">src</span> github.com/h0ffmann/picasso</div>
    </div>
    <div style="margin-top:24px;margin-left:auto;width:520px">${draw('dove', 520)}</div>
  </div>${foot(5)}`,
];

const browser = await chromium.launch(process.env.CHROMIUM ? { executablePath: process.env.CHROMIUM } : {});
const page = await browser.newPage({ viewport: { width: 1080, height: 1350 } });
for (const [i, s] of slides.entries()) {
  await page.setContent(`<!doctype html><html><head><meta charset="utf-8"><style>${css}</style></head><body>${s}</body></html>`);
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: path.join(here, `slide-${i + 1}.png`) });
}
await browser.close();
