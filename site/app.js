// History comes from history.json next to this page; the ouroboric-dev standings from the public
// GitHub API in the browser: no build, no token. Unauthenticated calls are limited to 60 an hour
// per IP, hence the ten-minute cache.
const ORG = 'ouroboric-dev';
const READINESS = { repo: 'ouroboric', dir: 'docs/1-company/readiness' };
const TTL = 10 * 60 * 1000;
const STATUSES = ['met', 'partial', 'missing'];

const $ = (id) => document.getElementById(id);

async function cached(url, as = 'json') {
  const key = `picasso:${url}`;
  try {
    const hit = JSON.parse(localStorage.getItem(key));
    if (hit && Date.now() - hit.at < TTL) return hit.body;
  } catch { /* storage unavailable: fetch every time */ }
  const res = await fetch(url, as === 'json' ? { headers: { Accept: 'application/vnd.github+json' } } : {});
  if (!res.ok) {
    const limited = res.status === 403 || res.status === 429;
    throw new Error(limited ? 'GitHub rate limit reached; try again in a few minutes.' : `${res.status} from ${url}`);
  }
  const body = as === 'json' ? await res.json() : await res.text();
  try { localStorage.setItem(key, JSON.stringify({ at: Date.now(), body })); } catch { /* ignore */ }
  return body;
}

function esc(s) {
  return s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

// Just enough markdown for the table cells: links, `code` and **bold**.
function inline(md, base) {
  return esc(md)
    .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (_, text, href) => {
      const url = new URL(href.replace(/&amp;/g, '&'), base).href;
      return `<a href="${esc(url)}">${text}</a>`;
    })
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
}

function parseReadiness(md) {
  const title = (md.match(/^#\s+(.+)$/m) || [])[1] || '';
  const bottom = (md.match(/\*\*Bottom line:\s*(.+?)\*\*/) || [])[1] || '';
  const items = md.split('\n')
    .filter((l) => /^\|\s*[A-Z]{2}-\d+\s*\|/.test(l))
    .map((l) => {
      const [id, question, status, evidence, todo] = l.split('|').slice(1, -1).map((c) => c.trim());
      return { id, question, status: status.toLowerCase(), evidence, todo: todo === '—' ? '' : todo };
    });
  return { title, bottom, items };
}

async function loadReadiness() {
  const listing = await cached(`https://api.github.com/repos/${ORG}/${READINESS.repo}/contents/${READINESS.dir}`);
  const latest = listing.filter((f) => f.name.endsWith('.md')).sort((a, b) => b.name.localeCompare(a.name))[0];
  if (!latest) throw new Error('No readiness assessment found.');
  const md = await cached(latest.download_url, 'text');
  const data = parseReadiness(md);
  if (!data.items.length) throw new Error(`Could not read the items table in ${latest.name}.`);

  $('readiness-src').href = latest.html_url;
  $('readiness-title').innerHTML = `${esc(data.title)}${data.bottom ? ` — ${esc(data.bottom)}` : ''}`;

  const counts = Object.fromEntries(STATUSES.map((s) => [s, data.items.filter((i) => i.status === s).length]));
  const total = data.items.length;
  $('score-met').textContent = counts.met;
  $('score-total').textContent = `/ ${total}`;
  $('bar').setAttribute('aria-label', STATUSES.map((s) => `${counts[s]} ${s}`).join(', '));
  $('bar').innerHTML = STATUSES.map((s) => `<span class="is-${s}" style="flex-grow:0"></span>`).join('');
  requestAnimationFrame(() => requestAnimationFrame(() => {
    $('bar').querySelectorAll('span').forEach((el, i) => { el.style.flexGrow = counts[STATUSES[i]]; });
  }));
  $('legend').innerHTML = STATUSES
    .map((s) => `<li><span class="dot is-${s}"></span><b>${counts[s]}</b> ${s}</li>`).join('');

  const base = latest.html_url;
  const order = { missing: 0, partial: 1, met: 2 };
  $('items').innerHTML = data.items
    .slice().sort((a, b) => (order[a.status] ?? 3) - (order[b.status] ?? 3) || a.id.localeCompare(b.id, undefined, { numeric: true }))
    .map((i) => `
      <li class="item" data-status="${esc(i.status)}">
        <span class="id">${esc(i.id)}</span>
        <span class="q">${inline(i.question, base)}</span>
        <span class="pill">${esc(i.status)}</span>
        ${i.todo ? `<p class="todo">${inline(i.todo, base)}</p>` : ''}
        <details><summary>Evidence</summary><p>${inline(i.evidence, base)}</p></details>
      </li>`).join('');

  $('scoreboard').hidden = false;
  $('filters').hidden = false;
  $('filters').addEventListener('click', (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;
    $('filters').querySelectorAll('button').forEach((b) => b.setAttribute('aria-pressed', b === btn));
    $('items').querySelectorAll('.item').forEach((li) => {
      li.hidden = btn.dataset.filter !== 'all' && li.dataset.status !== btn.dataset.filter;
    });
  });
}

const ago = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });
function relative(iso) {
  const s = (new Date(iso) - Date.now()) / 1000;
  for (const [unit, n] of [['year', 31536000], ['month', 2592000], ['day', 86400], ['hour', 3600], ['minute', 60]]) {
    if (Math.abs(s) >= n) return ago.format(Math.round(s / n), unit);
  }
  return 'just now';
}

const SORTS = {
  pushed: (a, b) => new Date(b.pushed_at) - new Date(a.pushed_at),
  stars: (a, b) => b.stargazers_count - a.stargazers_count || SORTS.pushed(a, b),
  issues: (a, b) => b.open_issues_count - a.open_issues_count || SORTS.pushed(a, b),
  size: (a, b) => b.size - a.size,
};

function renderRepos(repos) {
  const sorted = repos.slice().sort(SORTS[$('sort').value]);
  $('repos').innerHTML = sorted.map((r, i) => `
    <tr>
      <td class="rank">${i + 1}</td>
      <td>
        <a class="name" href="${esc(r.html_url)}">${esc(r.name)}</a>
        ${r.description ? `<div class="desc">${esc(r.description)}</div>` : ''}
      </td>
      <td class="num">${r.stargazers_count}</td>
      <td class="num">${r.open_issues_count}</td>
      <td class="num opt">${r.size >= 1024 ? `${(r.size / 1024).toFixed(1)} MB` : `${r.size} KB`}</td>
      <td class="when" title="${esc(r.pushed_at)}">${relative(r.pushed_at)}</td>
    </tr>`).join('');
}

async function loadRepos() {
  const repos = (await cached(`https://api.github.com/orgs/${ORG}/repos?per_page=100&type=public`))
    .filter((r) => !r.archived && !r.fork);
  renderRepos(repos);
  $('sort').addEventListener('change', () => renderRepos(repos));
}

function fail(id) {
  return (err) => { $(id).hidden = false; $(id).textContent = err.message; };
}

const DRAWINGS = {
  dove: 'A dove, one line, after Picasso',
  bull: 'A bull, one line, after Picasso',
  face: 'A face seen from two sides at once, one line, after Picasso',
  owl: 'An owl, one line, after Picasso',
  guitar: 'A cubist guitar, one line, after Picasso',
  cat: 'A seated cat, one line, after Picasso',
};
function draw() {
  const names = Object.keys(DRAWINGS).filter((n) => !$('drawing').src.endsWith(`/${n}.svg`));
  const name = names[Math.floor(Math.random() * names.length)];
  $('drawing').src = `drawings/${name}.svg`;
  $('drawing').alt = DRAWINGS[name];
}
draw();
$('redraw').addEventListener('click', draw);

const num = new Intl.NumberFormat('en');
const PR = (repo, n) => `<a href="${repo}/pull/${n}">#${n}</a>`;

async function loadHistory() {
  const res = await fetch('history.json');
  if (!res.ok) throw new Error(`history.json: ${res.status}`);
  const h = await res.json();
  const all = h.eras.flatMap((e) => e.commits);
  const prs = new Set(all.map((c) => c.pr).filter(Boolean));
  const sum = (k) => all.reduce((n, c) => n + c[k], 0);
  $('stats').innerHTML = [
    [all.length, 'commits on main'],
    [prs.size, 'pull requests merged'],
    [`+${num.format(sum('added'))}`, 'lines added'],
    [`−${num.format(sum('deleted'))}`, 'lines removed'],
    [Object.keys(h.labs).length, 'labs'],
    [all[0].date.slice(0, 7), 'first commit'],
  ].map(([v, l]) => `<div class="stat"><b>${esc(String(v))}</b><span>${l}</span></div>`).join('');

  const months = {};
  for (const c of all) months[c.date.slice(0, 7)] = (months[c.date.slice(0, 7)] || 0) + 1;
  const first = new Date(`${all[0].date.slice(0, 7)}-01`);
  const last = new Date(`${all.at(-1).date.slice(0, 7)}-01`);
  const span = [];
  for (const d = first; d <= last; d.setMonth(d.getMonth() + 1)) span.push(d.toISOString().slice(0, 7));
  const peak = Math.max(...Object.values(months));
  $('months').setAttribute('aria-label', `Commits per month, ${span[0]} to ${span.at(-1)}`);
  $('months').innerHTML = span.map((m) => {
    const n = months[m] || 0;
    return `<span title="${m}: ${n} commit${n === 1 ? '' : 's'}" style="--h:${n ? Math.max(6, (n / peak) * 100) : 0}%"></span>`;
  }).join('');

  $('eras').innerHTML = h.eras.map((e, i) => `
    <li class="era">
      <div class="era-head">
        <span class="era-n">${i + 1}</span>
        <div>
          <h3>${esc(e.title)}</h3>
          <p class="when">${e.from === e.to ? e.from : `${e.from} → ${e.to}`} · ${e.commits.length} commits</p>
        </div>
      </div>
      <p>${esc(e.blurb)}</p>
      <details>
        <summary>Every change</summary>
        <ul class="log">${e.commits.slice().reverse().map((c) => `
          <li${c.bot ? ' class="bot"' : ''}>
            <span class="date">${c.date}</span>
            <span class="what">${esc(c.subject.replace(/ \(#\d+\)$/, ''))}</span>
            <span class="ref">${c.pr ? PR(h.repo, c.pr) : `<a href="${h.repo}/commit/${c.sha}">${c.sha}</a>`}</span>
          </li>`).join('')}
        </ul>
      </details>
    </li>`).join('');

  $('labs-list').innerHTML = Object.entries(h.labs).map(([name, summary]) => `
    <li><a href="${h.repo}/tree/main/labs/${encodeURIComponent(name)}">${esc(name)}</a><p>${esc(summary)}</p></li>`).join('');
}

Promise.allSettled([
  loadHistory().catch(fail('history-error')),
  loadReadiness().catch(fail('readiness-error')),
  loadRepos().catch(fail('repos-error')),
]).then(() => {
  $('updated').textContent = `Updated ${new Date().toLocaleString()}`;
});
