// Browser and Intl glue the Gleam modules cannot express. Unauthenticated GitHub API calls are
// limited to 60 an hour per IP, hence the ten-minute localStorage cache.
const TTL = 10 * 60 * 1000;

export function get(url, cache, onOk, onError) {
  const key = `picasso:v2:${url}`;
  if (cache) {
    try {
      const hit = JSON.parse(localStorage.getItem(key));
      if (hit && Date.now() - hit.at < TTL) return void onOk(hit.body);
    } catch { /* storage unavailable: fetch every time */ }
  }
  const headers = url.startsWith('https://api.github.com/') ? { Accept: 'application/vnd.github+json' } : {};
  fetch(url, { headers })
    .then(async (res) => {
      if (!res.ok) {
        const limited = res.status === 403 || res.status === 429;
        throw new Error(limited ? 'GitHub rate limit reached; try again in a few minutes.' : `${res.status} from ${url}`);
      }
      const body = await res.text();
      if (cache) {
        try { localStorage.setItem(key, JSON.stringify({ at: Date.now(), body })); } catch { /* ignore */ }
      }
      onOk(body);
    })
    .catch((err) => onError(err.message));
}

export function resolve_url(href, base) {
  try { return new URL(href, base).href; } catch { return href; }
}

const ago = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });
export function relative_time(iso) {
  const s = (new Date(iso) - Date.now()) / 1000;
  for (const [unit, n] of [['year', 31536000], ['month', 2592000], ['day', 86400], ['hour', 3600], ['minute', 60]]) {
    if (Math.abs(s) >= n) return ago.format(Math.round(s / n), unit);
  }
  return 'just now';
}

export function now_local() {
  return new Date().toLocaleString();
}
