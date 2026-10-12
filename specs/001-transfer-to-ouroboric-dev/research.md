---
title: "Research: what the transfer touches"
status: draft
date: 2026-10-12
related: [spec.md, plan.md, ../../docs/adr/0001-donate-picasso-to-ouroboric-dev.md]
---

# Research: what the transfer touches

Phase 0 of [plan.md](plan.md). It lists every reference to the repository's old names on
2026-10-12. Each list comes from `git grep -nE "h0ffmann/(nix-config|picasso)"` on a fresh clone of
`main`, cross-checked with GitHub code search (`user:h0ffmann`, `org:marola-dev`). Line numbers are
from that date. Re-run the grep before each task, because they move.

## R1. What GitHub does on a transfer

Source: [Transferring a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/transferring-a-repository)
and [Renaming a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository),
fetched 2026-10-12.

- These move with the repository: issues, pull requests, wiki, stars, watchers, Git LFS objects,
  webhooks, services, secrets and deploy keys. Collaborators stay, and the old owner becomes a
  collaborator.
- Web and git URLs redirect. GitHub Pages does not.
- The redirect is "permanently deleted" if a repository or fork is created at the old location.
  A name that had more than 100 clones or Actions uses in the week before may be retired instead.
- Transferring needs admin rights on the repository and permission to create repositories in the
  target org.
- Renamed repositories: "GitHub will not redirect calls to an action hosted by a renamed
  repository", so a workflow fails with "repository not found". The docs say nothing about Actions
  after a *transfer*. Community reports say the redirect works for transfers but breaks easily, and
  GitHub's own advice is to use the canonical name.

**Decision:** no reference may rely on a redirect. Every `uses:`, flake URL, submodule URL and
metadata URL moves to `ouroboric-dev/picasso`.

## R2. Consumers outside this repo

| Repo | File:line | Kind | Today |
|---|---|---|---|
| h0ffmann/h0ffmann | `flake.nix:4` + `flake.lock` (`publisher`) | flake input | `github:h0ffmann/nix-config?dir=labs/publisher` |
| h0ffmann/h0ffmann | `.github/workflows/cv.yml:32` | composite Action | `uses: h0ffmann/nix-config/labs/publisher@main` |
| h0ffmann/h0ffmann | `cv/test_prepare.py:55` | test fixture (badge text) | old URL inside a string; does not resolve anything, leave it |
| h0ffmann/ww3-gpu | `.gitmodules:3` | submodule (sparse, `labs/pratico`) | `git@github.com:h0ffmann/nix-config.git` |
| h0ffmann/ww3-gpu | `scripts/ww-lab-tool-setup.sh:19` | submodule setup | same URL |
| h0ffmann/ww3-gpu | `flake.nix:7` + `flake.lock` | flake input | `publisher` |
| h0ffmann/ww3-gpu | `.github/workflows/pubs.yml:24` | composite Action | `labs/publisher@main` |
| h0ffmann/ww3-gpu | `.github/workflows/profile-activity.yml:16` | reusable workflow | `profile-ping.yml@main` |
| h0ffmann/ww3-gpu | `docs/TOOLCHAIN.md:4`, `pubs/README.md:23`, `docs/GLOSSARY.md:466`, `.claude/commands/update-sub-modules.md:14` | docs links | |
| h0ffmann/gcp-agentic-architect | `flake.nix:7,10,14` + `flake.lock` | flake inputs | `publisher`, `lint`, `agentic` |
| h0ffmann/gcp-agentic-architect | `.github/workflows/pubs.yml:24` | composite Action | `labs/publisher@main` |
| h0ffmann/gcp-agentic-architect | `.github/workflows/profile-activity.yml:16` | reusable workflow | `profile-ping.yml@main` |
| h0ffmann/gcp-agentic-architect | `README.md:23,76,94,96,97,140,157`, `AGENTS.md:15`, `justfile:67` | docs links | |
| marola-dev/marola | `flake.nix:9,13` + `flake.lock` | flake inputs | `lint` on `main`; `agentic` on the branch `labs/agentic` |
| marola-dev/marola | `.github/workflows/profile-activity.yml:16` | reusable workflow | `profile-ping.yml@main` |
| marola-dev/marola | `justfile:326`, `docs/3-Ways-of-working/PHILOSOPHY.md:140` | docs | |
| marola-dev/marola-skills | `data/sources.json` (`own`) | skills index owners | lists `marola-dev`, `h0ffmann`; picasso's `.claude/skills/` leaves the index unless `ouroboric-dev` is added |

These are left alone on purpose, because they are dated records and are never edited: marola's
`docs/MIPs/MIP-0060*`, `MIP-0066`, `MIP-0070`, h0ffmann/h0ffmann's and ww3-gpu's
`docs/superpowers/**`, and gcp-agentic-architect's `docs/PROMPT-SERIES_202609.md`.

ww-lab, named as a consumer in `AGENTS.md`, is ww3-gpu under its old name:
`git ls-remote https://github.com/h0ffmann/ww-lab HEAD` returns the same commit as ww3-gpu
(`fe472ab`). The ww3-gpu rows cover it.

marola's `agentic` input follows the branch `labs/agentic` (still on the remote, `ce92036`), not
`main`. Moving the URL keeps the ref; whether it should go back to `main` is marola's call
(MIP-0060 task 2 says `main`).

## R3. References inside picasso

| File:line | What |
|---|---|
| `README.md:12` | CI badge |
| `README.md:42,80,324–404,422,428` | `nix run` / `nix flake show` / `inputs` / `uses:` examples |
| `README.md:183` | publisher reuse row |
| `README.md:449–452` | History table PR links (GitHub redirects these; update so they are not left behind) |
| `labs/{publisher,lint,agentic,cuda,present}/README.md`, `labs/pratico/README.md:86` | "Reusing it from another repository" blocks |
| `labs/publisher/README.md:117`, `labs/publisher/action.yml:3` | `uses:` example |
| `labs/pratico/scripts/ww-lab-submodule.sh:19` | submodule URL (still `nix-config`) |
| `.github/workflows/profile-ping.yml:14` | caller example in the header |
| `.github/ISSUE_TEMPLATE/config.yml:4` | contact link |
| `.zenodo.json:41` | `related_identifiers` `isSupplementTo` |
| `scripts/citation.py:36` | `HOMEPAGE` → `CITATION.cff:25–26` (generated, `just citation`) |
| `site/history.py:12`, `site/history.json` | repo URL; regenerate the JSON, never hand-edit it |
| `site/index.html:29,67,78,142` | links |
| `DESCRIPTION.md:12–14`, `TAGS.md:32` | `gh repo edit` commands |
| `AGENTS.md:8,123` | name history; the lab checklist's `inputs.<lab>.url` |

These are local paths or cache keys, not URLs, and stay as they are (`AGENTS.md` already says so):
`configuration.nix:407` (`/home/h0ffmann/nix-config`), and `justfile:64` (`marola-graph/nix-config`).

## R4. Zenodo and citation

- There is no tag and no Zenodo record (`git tag` is empty; no DOI in `.zenodo.json`).
- Zenodo lists the repositories its GitHub OAuth app can see. An org that restricts third-party
  apps has to approve Zenodo first (Org settings → Third-party access). Only an org owner, or a
  member with admin on the repo, can turn it on.
- `.zenodo.json` keeps the person as the creator. A transfer is not a copyright assignment, so
  ouroboric-dev is not added as a creator. A `HostingInstitution` contributor is possible later and
  is not decided here.
- `citation.yml` fails when `CITATION.cff` drifts from `.zenodo.json`. Edit `.zenodo.json` and
  `scripts/citation.py`, then run `just citation`.

## R5. Hosting (#85)

Every option in #85 is affected, in a different way:

- **GitHub Pages:** the `*.github.io` URL changes and is not redirected. A custom domain keeps the
  public URL, but it has to be verified on the org that owns the Pages site.
- **Porkbun GitHub Connect / Cloudflare Pages:** their GitHub app or OAuth grant has to cover
  `ouroboric-dev`.
- **Porkbun drag-and-drop:** not affected.

**Decision:** #85 is settled after the transfer, so its setup is done once, against the final owner.
