---
title: "ADR 0001: Donate picasso to ouroboric-dev"
status: draft
date: 2026-10-12
related:
  - ../../specs/001-transfer-to-ouroboric-dev/spec.md
  - ../../specs/001-transfer-to-ouroboric-dev/plan.md
  - ../../specs/001-transfer-to-ouroboric-dev/tasks.md
  - https://github.com/h0ffmann/picasso/issues/79
  - https://github.com/h0ffmann/picasso/issues/85
---

# ADR 0001: Donate picasso to ouroboric-dev

## Context

picasso is a personal repository (`h0ffmann/picasso`, renamed from `h0ffmann/nix-config` on
2026-10-12, [#79](https://github.com/h0ffmann/picasso/issues/79)). Its labs are borrowed by five
other repositories, as flake inputs, a sparse submodule, a composite Action and a reusable
workflow. Its site already reports on the [ouroboric-dev](https://github.com/ouroboric-dev)
organisation and must show the Ouroboric logo (`site/check.py`).

The owner wants picasso to belong to ouroboric-dev: "donate" it to the org. Three things hold today:

- **No Zenodo record yet.** There is no tag and no DOI. `.zenodo.json` and `CITATION.cff` exist
  (#84) and name `https://github.com/h0ffmann/picasso`.
- **No public site yet.** Where `site/` is hosted is still open in
  [#85](https://github.com/h0ffmann/picasso/issues/85).
- **The consumers still say `nix-config`.** Every reference outside this repo names
  `h0ffmann/nix-config` ([research](../../specs/001-transfer-to-ouroboric-dev/research.md)). GitHub
  redirects a renamed repository for the web, git and the API, but "will not redirect calls to an
  action hosted by a renamed repository"
  ([GitHub docs, renaming a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository)).
  So the `uses: h0ffmann/nix-config/...` lines in four repositories are likely failing already.
  This was read from the docs, not observed in a run.

## Options

1. **Transfer the repository** (Settings → General → Transfer ownership). Issues, pull requests,
   wiki, stars, watchers, webhooks, secrets and deploy keys move with it. GitHub redirects the web
   and git URLs from the old location. It does not redirect GitHub Pages
   ([GitHub docs, transferring a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/transferring-a-repository)).
2. **Create `ouroboric-dev/picasso` and push the history to it**, then archive the personal repo.
   This keeps the git history but loses issues, pull requests and stars, and gives no redirect.
3. **Fork into the org.** The fork stays tied to the personal upstream, and consumers would follow
   the wrong one.
4. **Keep it personal and list it in the org.** Nothing breaks, but nothing is donated.

## Decision

**Decided 2026-10-12:** transfer `h0ffmann/picasso` to `ouroboric-dev/picasso` with GitHub's
transfer, keeping the name `picasso`. Then move every reference, inside and outside the repo, to
the new name in the same window. Do not rely on any redirect. The transfer is done by the owner,
never by an agent.

**Decided 2026-10-12:** the transfer comes **before** the first Zenodo release, and the Zenodo
GitHub integration is turned on only after the transfer. This is the reasoning of #79 applied to
the owner instead of the name. Zenodo writes the repository URL into each version it archives, so
every version stays consistent only if version one already carries the final URL.

**Decided 2026-10-12:** the consumer fix for the rename (`nix-config` → `picasso`) and the fix for
the transfer (`h0ffmann` → `ouroboric-dev`) are **one** sweep, aimed straight at
`ouroboric-dev/picasso`. This holds as long as the transfer is not delayed. If it waits more than
a few days, do an interim sweep to `h0ffmann/picasso` first, because the Action lines are already
broken.

**Decided 2026-10-12:** a transfer moves the hosting, not the copyright. `LICENSE` stays MIT with
its current copyright line, and the authors in `.zenodo.json` stay as they are. Whether picasso
adopts the org's licence layout (REUSE, CC BY 4.0 for docs) is a separate question, listed below.

## Consequences

**What breaks, and the fix for each.** The full inventory, with `file:line` for every reference,
is in [research.md](../../specs/001-transfer-to-ouroboric-dev/research.md).

| Surface | What breaks | Fix |
|---|---|---|
| Flake inputs (`github:h0ffmann/nix-config?dir=labs/…`) in h0ffmann/h0ffmann, ww3-gpu, gcp-agentic-architect, marola | Probably nothing on the day: Nix fetches through the API, which redirects. But each `flake.lock` records `owner`/`repo`, so every pinned rev depends on a two-hop redirect (`nix-config` → `picasso` → org). That redirect dies if anyone creates a repo at an old location. | Change `url` to `github:ouroboric-dev/picasso?dir=labs/<lab>`, then `nix flake update <input>` in the same PR. CI runs `--no-update-lock-file`, so a URL change without a re-lock fails. |
| Submodule URL (ww3-gpu `.gitmodules`, `scripts/ww-lab-tool-setup.sh`, and picasso's own `labs/pratico/scripts/ww-lab-submodule.sh`) | Git redirects, so clones keep working until a name is reused | `url = git@github.com:ouroboric-dev/picasso.git`, then `git submodule sync`. The submodule directory stays `nix-config/`. |
| Workflow `uses:` lines: `…/labs/publisher@main` (h0ffmann/h0ffmann, ww3-gpu, gcp-agentic-architect) and `…/.github/workflows/profile-ping.yml@main` (ww3-gpu, gcp-agentic-architect, marola) | Actions do not follow rename redirects, so these probably fail already. A transfer redirect for Actions is not documented. | `uses: ouroboric-dev/picasso/labs/publisher@main` and `uses: ouroboric-dev/picasso/.github/workflows/profile-ping.yml@main`. A caller in an org with an allowed-actions list must add `ouroboric-dev/picasso/*`. |
| Zenodo / citation | Nothing is archived yet, so nothing breaks. A release made before the move would carry the old URL forever. | Change `.zenodo.json` `related_identifiers[0]` and `scripts/citation.py` `HOMEPAGE`, then `just citation`. Approve Zenodo's OAuth app for ouroboric-dev, turn on the repo in Zenodo, then tag `v0.1.0`. |
| Custom domain / GitHub Pages (#85) | GitHub Pages URLs are never redirected. `h0ffmann.github.io/picasso` becomes `ouroboric-dev.github.io/picasso`. A domain verified on the personal account does not cover the org. Porkbun's GitHub Connect and Cloudflare Pages need access to the org repo again. | Settle #85 after the transfer, under the org. If the custom domain is used with GitHub Pages, verify it on ouroboric-dev first. |
| GitHub redirects | Web, git and API redirect, but only until a repository is created at an old location. `h0ffmann/picasso` and `h0ffmann/nix-config` must never be created again. | Treat redirects as a grace period, not a fix. Every reference moves; the old names are written down as reserved in `AGENTS.md`. |
| Profile and indexes | picasso leaves the personal account. The metrics languages card (owned repos only) drops it. marola-skills' `data/sources.json` indexes skills only for the owners `marola-dev` and `h0ffmann`, so picasso's ten vendored skills drop out of the index. | Pin picasso on the profile. Add `ouroboric-dev` to `own` in marola-skills `data/sources.json`. |
| Access | Org third-party app restrictions can block the Claude GitHub App, Zenodo and Porkbun. The org's default `GITHUB_TOKEN` may be read-only (picasso's workflows already ask only for `contents: read`). This Claude project lists `h0ffmann/picasso`. | Install or approve each app for ouroboric-dev. Change the project's repository to `ouroboric-dev/picasso`. |

**Good:** picasso sits next to the org it reports on. Issues, PRs, stars and history move intact.
The Zenodo record starts under its final home.

**Bad:** a second URL change in one day for every consumer. The redirects cover a broken reference
silently for a while, then can stop working all at once.

## Open questions

- Does ouroboric-dev want picasso under REUSE, with CC BY 4.0 for the docs as in
  [its legal page](https://github.com/ouroboric-dev/ouroboric/blob/main/docs/1-company/legal/README.md)?
  This ADR keeps MIT for everything.
- Should picasso count as a leaf under the org's docs standard (`docs/architecture.md`)? This ADR
  adds nothing for it.
- Should the site's ouroboric-dev standings list picasso itself once it is an org repo? Today it
  would show up there automatically.
