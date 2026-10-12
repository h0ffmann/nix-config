# site

picasso's page: the repository's history since 2024 (every commit on `main`, era by era), the
labs' cards, an original one-line drawing after Picasso picked at random on each visit, and the
live standings of the [ouroboric-dev](https://github.com/ouroboric-dev) organisation (its latest
readiness assessment and its public repositories, ranked).

No build and no token. `history.json` is generated; refresh it from a full clone after merges:

```console
python3 site/history.py               # writes site/history.json
python3 -m http.server -d site 8000   # then open http://localhost:8000
```

The standings come from the public GitHub API at view time, cached ten minutes per browser
because unauthenticated calls are limited to 60 an hour per IP.

Published at <https://h0ffmann.github.io/picasso/> by `.github/workflows/pages.yml` on every push
to `main` that touches `site/`. Where it is hosted and the move to a custom domain are planned in
[#85](https://github.com/h0ffmann/picasso/issues/85) and [`plan/hosting-plan.pdf`](plan/hosting-plan.pdf),
which the page links from its header.

![Desktop, dark](screenshots/desktop-dark.png)

In the screenshots the ouroboric-dev repository numbers are mocked; everything else is real.
