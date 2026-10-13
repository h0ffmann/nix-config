---
title: "REA: ouroboric-dev into picasso"
status: draft
date: 2026-10-13
related: [../readiness/2026-10-13-adoption-by-ouroboric-dev.md, ../../.claude/skills/ouroboric-sharingan/SKILL.md]
style: research
---

# REA: ouroboric-dev into picasso

This report is the output of the `ouroboric-sharingan` skill (Read, Evaluate, Adopt). An agent
made it. The human did not review it yet. The skill's `READINESS.md` waits for that review.

Scanned 11 repositories on 2026-10-13. 17 items are evaluated: 3 are borrowed in this pull
request, 2 were in picasso before, and 12 are not taken. Destination licences: AGPL-3.0-only for
code, CC-BY-4.0 for documentation (`REUSE.toml`). No file was copied from ouroboric-dev.

## Method

1. `gh repo list ouroboric-dev --limit 100` gave 11 repositories. All are public. None is a fork
   and none is archived.
2. Each repository was cloned into a scratch directory, outside this repository. No file from a
   clone was run.
3. `python3 -I .claude/skills/ouroboric-sharingan/scripts/licence_scan.py --into <id> <clone>`
   was run on each clone, one time with `CC-BY-4.0` and one time with `AGPL-3.0-only`. All 22
   runs gave exit code 0.
4. Each item in the table was opened and read. Its licence was read from the `REUSE.toml` of its
   repository.

## Sources

Each row of this report cites one of these commits.

| Repository | Commit | Root licence (`LICENSE`) | Scan flags |
|---|---|---|---|
| [ouroboric](https://github.com/ouroboric-dev/ouroboric/tree/b355b1d52d6906f80447fe84283f705403533d0b) | `b355b1d` | CC-BY-4.0 | `mixed`, `unknown-licence` |
| [yggdrasil](https://github.com/ouroboric-dev/yggdrasil/tree/ffedea7c476d10c04498d5db74596a72a5ab0cbb) | `ffedea7` | AGPL-3.0 | `mixed` |
| [asgard](https://github.com/ouroboric-dev/asgard/tree/1acab205610d3c9d816076bf83baa0b333c4dd08) | `1acab20` | AGPL-3.0 | `mixed` |
| [havamal](https://github.com/ouroboric-dev/havamal/tree/4100f7aa193eeadd9791f464a04ee42228daee96) | `4100f7a` | AGPL-3.0 | `mixed` |
| [gungnir](https://github.com/ouroboric-dev/gungnir/tree/3cf58077505cd525a00c87a1f12d8ea7c7809247) | `3cf5807` | AGPL-3.0 | `mixed` |
| [odin](https://github.com/ouroboric-dev/odin/tree/a5c3eb7fba7ec3cf915e6d0fc1a43e18bd3b6cc6) | `a5c3eb7` | AGPL-3.0 | `mixed` |
| [gleipnir](https://github.com/ouroboric-dev/gleipnir/tree/7af3ca850b267b6b285a21ecf83f7827c63161e1) | `7af3ca8` | AGPL-3.0 | `mixed` |
| [jormungandr](https://github.com/ouroboric-dev/jormungandr/tree/13356d654273dab3cbfe97a987b279b4318308ad) | `13356d6` | AGPL-3.0 | `mixed` |
| [realm-web](https://github.com/ouroboric-dev/realm-web/tree/053bf6aef43f662d84bafc5bf804f20b516c2a61) | `053bf6a` | AGPL-3.0 | `mixed` |
| [ouroboric-packages](https://github.com/ouroboric-dev/ouroboric-packages/tree/fb4ae8402835bee6291bf708c9b1dca99503b405) | `fb4ae84` | MIT | none |
| [.github](https://github.com/ouroboric-dev/.github/tree/b799793319aaf4138e9733bcdda63b7a31cd7eb4) | `b799793` | MIT | none |

`mixed` means that the licence changes with the path. In the nine `mixed` repositories, the
`REUSE.toml` gives CC-BY-4.0 to documentation and AGPL-3.0-only to code. `asgard` and `realm-web`
also give MIT to `templates/`. The
`unknown-licence` flag in `ouroboric` is `LICENSES/LicenseRef-Ouroboric-Trademark.txt`: the logo
files are trademarks, and nothing here uses them. All copyright lines name Bruno Guilhermo de
Barros Valério (2026).

## Borrowed in this pull request

A `borrow` verdict means that picasso has its own text, written from the idea, with credit. The
licence permitted more (`reuse` or `reuse-file`) for each row. `borrow` was used because a copy
needs a new `REUSE.toml` entry, and `AGENTS.md` reserves `REUSE.toml` for the human.

| Item | Upstream at commit | Licence (from) | Verdict | Why take it | How to credit |
|---|---|---|---|---|---|
| Readiness checklist: the item ids and the three levels | [asgard@1acab20](https://github.com/ouroboric-dev/asgard/blob/1acab205610d3c9d816076bf83baa0b333c4dd08/templates/readiness/checklist.md) | MIT (`REUSE.toml`, `templates/**`) | borrow; the scan permits `reuse-file` into CC-BY-4.0 | picasso had no assessment against a known list | "approach borrowed from ouroboric-dev/asgard@1acab20 (MIT)" |
| Readiness assessment: the layout (bottom line, counts, one row for each item with evidence) | [ouroboric@b355b1d](https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/docs/1-company/readiness/2026-10-11-ready-to-build.md) | CC-BY-4.0 (`REUSE.toml`, `**`) | borrow; the scan permits `reuse` into CC-BY-4.0 | the same layout lets a reader compare the two assessments | "approach borrowed from ouroboric-dev/ouroboric@b355b1d (CC-BY-4.0)" |
| Document front matter (`title`, `status`, `date`, `related`, `style`) and dated file names | [ouroboric@b355b1d, docs-standard.md §5](https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/docs/4-ways-of-working/docs-standard.md) | CC-BY-4.0 (`REUSE.toml`, `**`) | borrow; the scan permits `reuse` into CC-BY-4.0 | a record needs a status and a date | "approach borrowed from ouroboric-dev/ouroboric@b355b1d (CC-BY-4.0)" |

The credit is in the README's License table and in the two documents that use the items.

## In picasso before this report

| Item | Upstream at commit | Licence (from) | Where it is in picasso |
|---|---|---|---|
| The AGPL-3.0-only and CC-BY-4.0 split, recorded in `REUSE.toml` without file headers | [ouroboric@b355b1d, legal/README.md](https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/docs/1-company/legal/README.md) | CC-BY-4.0 (`REUSE.toml`, `**`) | `LICENSE`, `REUSE.toml`, README License section (#105, #109) |
| The `guardrail-change` approval point | [ouroboric@b355b1d, spec-driven-development.md §4](https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/docs/4-ways-of-working/spec-driven-development.md) | CC-BY-4.0 (`REUSE.toml`, `**`) | `AGENTS.md`, "Files that need a human's approval" (#109) |

## Not taken

- **`## Invariants` section and a short `AGENTS.md`** (ouroboric@b355b1d `AGENTS.md`, CC-BY-4.0,
  `reuse` permitted): picasso needs it for readiness item RB-05, but `AGENTS.md` is a reserved
  file. See "Needs a human".
- **`scripts/check-repos.sh`** (ouroboric@b355b1d, AGPL-3.0-only, `reuse` permitted into picasso
  code): it checks settings, security, the ruleset, `reuse lint`, `AGENTS.md` and gitleaks. Not
  taken: the organisation name and the repository lists are fixed in the script, and it needs
  side-by-side clones.
- **`scripts/diagrams.sh`** (ouroboric@b355b1d, AGPL-3.0-only, `reuse` permitted): it renders
  Mermaid and D2 sources with a local Kroki 0.32.1. Not taken: picasso has no diagram sources.
- **`scripts/as-bot.sh`, `create-repo.sh`, `setup-repo.sh`, `create-pr-bot.sh` and their tests**
  (ouroboric@b355b1d, AGPL-3.0-only): they create and protect the organisation's repositories.
  Not needed: picasso is one repository.
- **`.devcontainer/devcontainer.json`** (six component repositories, AGPL-3.0-only): not needed.
  A lab gives the tools through Nix.
- **Pinned gitleaks pre-commit hook**: `check-repos.sh` looks for it, but no ouroboric-dev
  repository has a `.pre-commit-config.yaml` at these commits. It is a design. Cite only.
- **`skills.lock`** (ouroboric@b355b1d `writing-styles.md` §5, CC-BY-4.0): a design. No
  `skills.lock` file is in a repository at these commits. picasso records each vendored skill's
  upstream, commit and licence in `.claude/skills/README.md`, without a hash for each file. Cite
  only.
- **Journal format** (ouroboric@b355b1d `docs/6-journal/README.md`, CC-BY-4.0, `reuse`
  permitted): picasso has no journal (readiness item RB-17). Not taken here: an entry must come
  from real work, and the human decides if picasso keeps a journal.
- **Numbered `docs/` tree** (ouroboric@b355b1d `docs-standard.md` §1, CC-BY-4.0): not taken. It
  moves each file under `docs/` and changes the README's Papers table and the paths in
  `REUSE.toml`.
- **Organisation defaults: issue forms, pull request template, code of conduct, security policy**
  (.github@b799793, MIT, `reuse` permitted into AGPL-3.0-only, `reuse-file` into CC-BY-4.0):
  picasso has its own issue forms and pull request template. See "Needs a human" for the rest.
- **`TRADEMARKS.md`** (ouroboric@b355b1d, CC-BY-4.0): the text is about the Ouroboric marks. Not
  applicable.
- **`ouroboric-packages`** (fb4ae84, MIT): a package that holds a name on PyPI. Not needed.

## Needs a human

This report is not legal advice.

1. **Review this report.** The skill's `READINESS.md` has an open item: one real REA with its
   report reviewed by the human. This pull request does not tick that item.
2. **`AGENTS.md` shape (reserved file).** `ouroboric/scripts/check-repos.sh` passes a repository
   only if its `AGENTS.md` has a `## Invariants` heading or links to the Yggdrasil invariants.
   `grep -c '^## Invariants' AGENTS.md` gives 0 here. The docs standard gives about 100 lines to a
   leaf's `AGENTS.md`. picasso's has 327.
3. **Community files.** GitHub shows picasso's code of conduct and contributing guide from
   `h0ffmann/.github`. That repository is a fork of `ouroboric-dev/.github` with no changes
   (`gh api repos/h0ffmann/.github/compare/ouroboric-dev:main...h0ffmann:main` gives `identical`).
   Thus the contributing guide that GitHub shows for picasso says "Ouroboric is read-only for
   now". Its `SECURITY.md` tells the reader to use private vulnerability reporting, which is off
   in picasso (`gh api repos/h0ffmann/picasso/private-vulnerability-reporting` gives
   `{"enabled":false}`). The owner decides the text, and only the owner can change the setting.
4. **Trademark licence.** The scan did not recognise
   `LICENSES/LicenseRef-Ouroboric-Trademark.txt`. Nothing here uses the files that it covers.
   picasso's site loads the Ouroboric logo from the ouroboric repository (`AGENTS.md`, "The site,
   the drawings and third-party rights"), as before.

## Cite

No ouroboric-dev repository has a `CITATION.cff`, a `.zenodo.json` or a DOI at these commits (the
`citation` field of each scan is empty). Cite a repository by its URL at the commit in "Sources".
