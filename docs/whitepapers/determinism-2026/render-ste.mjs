// Prints the repo root's WHITEPAPER.md (the ASD-STE100 text) to WHITEPAPER.pdf with headless
// Chromium, in a plain technical-manual look; PICASSOPAPER.pdf (render.mjs) keeps the coloured one.
// Needs pandoc on PATH (`nix shell nixpkgs#pandoc`) and network for Google Fonts.
//   node render-ste.mjs        (Playwright on the module path; CHROMIUM=<path> to pick a binary)
import { chromium } from 'playwright';
import { execFileSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';
import { mkdtempSync, writeFileSync } from 'node:fs';
import os from 'node:os';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const body = execFileSync('pandoc', [path.join(root, 'WHITEPAPER.md'), '-f', 'gfm', '-t', 'html5'], { encoding: 'utf8' });
const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">
<base href="${pathToFileURL(root + '/').href}">
<link href="https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,400;0,600;1,400&family=JetBrains+Mono&display=swap" rel="stylesheet">
<style>
  @page { size: A4; margin: 20mm 20mm 22mm; }
  body { margin: 0; color: #111; font: 400 10pt/1.5 Inter, sans-serif; }
  h1 { font-size: 20pt; line-height: 1.2; margin: 0 0 .6em; }
  h2 { font-size: 13pt; margin: 1.4em 0 .5em; border-bottom: 1px solid #111; padding-bottom: 2px; break-after: avoid; }
  h3 { font-size: 11pt; margin: 1.1em 0 .4em; break-after: avoid; }
  p, li { hyphens: auto; } a { color: #111; }
  code { font: .88em 'JetBrains Mono', monospace; }
  table { border-collapse: collapse; width: 100%; margin: .6em 0 1em; font-size: 8.6pt; break-inside: avoid; }
  th, td { border: 1px solid #999; padding: 3px 5px; text-align: left; vertical-align: top; }
  th { background: #eee; }
  blockquote { margin: 1em 0; padding: .4em 1em; border-left: 3px solid #111; background: #f4f4f4; }
  img { display: block; max-width: 45mm; margin: 1em auto; }
  p[align=center] img { max-width: 18mm; }
</style></head><body>${body}</body></html>`;

const browser = await chromium.launch(process.env.CHROMIUM ? { executablePath: process.env.CHROMIUM } : {});
const page = await browser.newPage();
// From a file:// page, so the <base> resolves the drawings on disk.
const tmp = path.join(mkdtempSync(path.join(os.tmpdir(), 'ste-')), 'whitepaper.html');
writeFileSync(tmp, html);
await page.goto(pathToFileURL(tmp).href, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
const foot = 'font:7.5pt Inter,sans-serif;color:#555;width:100%;padding:0 20mm;display:flex;justify-content:space-between';
await page.pdf({
  path: path.join(root, 'WHITEPAPER.pdf'),
  format: 'A4',
  printBackground: true,
  preferCSSPageSize: true,
  displayHeaderFooter: true,
  headerTemplate: '<span></span>',
  footerTemplate: `<div style="${foot}"><span>h0ffmann/picasso · same inputs, same factory · ASD-STE100 text</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`,
});
await browser.close();
