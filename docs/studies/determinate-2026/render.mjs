// Prints study.html to study.pdf beside it with headless Chromium, as the whitepaper's render.mjs does.
//   node render.mjs            (Playwright on the module path; CHROMIUM=<path> to pick a binary)
import { chromium } from 'playwright';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const browser = await chromium.launch(process.env.CHROMIUM ? { executablePath: process.env.CHROMIUM } : {});
const page = await browser.newPage();
await page.goto(pathToFileURL(path.join(here, 'study.html')).href, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
const foot = 'font:7.5pt Inter,sans-serif;color:#4F5868;width:100%;padding:0 17mm;display:flex;justify-content:space-between';
await page.pdf({
  path: path.join(here, 'study.pdf'),
  format: 'A4',
  printBackground: true,
  preferCSSPageSize: true,
  displayHeaderFooter: true,
  headerTemplate: '<span></span>',
  footerTemplate: `<div style="${foot}"><span>h0ffmann/picasso · picasso and Determinate Nix · 12 October 2026</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`,
});
await browser.close();
