---
title: "Tasks: transfer picasso to ouroboric-dev"
status: draft
date: 2026-10-12
related: [spec.md, plan.md, research.md, quickstart.md]
---

# Tasks: Transfer picasso to ouroboric-dev

**Input**: design documents in `specs/001-transfer-to-ouroboric-dev/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [quickstart.md](quickstart.md)

**Format**: `- [ ] T### [P?] [Story] [Who] description with file path`. Below each task:
**Check** (the command or observation that proves the task is done) and **Depends** (task ids).

- **[P]**: can run in parallel (a different repository or file, no dependency on an open task)
- **[US1]–[US4]**: the user stories in [spec.md](spec.md)
- **[owner]**: only the account owner can do it ([quickstart.md](quickstart.md)). **[agent]**:
  a PR an agent can write.

Line numbers are from 2026-10-12 ([research.md](research.md)). Re-run
`git grep -nE "h0ffmann/(nix-config|picasso)"` before each agent task.

## Phase 1: Setup (owner)

- [ ] T001 [US2] [owner] Run the org checks in quickstart §0 (repository creation, name free,
  marola-dev allowed-actions list, ouroboric-dev Actions defaults, counts written down, Zenodo off).
  **Check**: `https://github.com/ouroboric-dev/picasso` returns 404, and the counts are written
  down. **Depends**: none.
- [ ] T002 [US2] [owner] Transfer `h0ffmann/picasso` to `ouroboric-dev`, keeping the name
  (quickstart §1).
  **Check**: the counts match T001's (SC-003), and `h0ffmann/picasso` redirects. **Depends**: T001.
- [ ] T003 [US2] [owner] Approve the Claude GitHub App and Zenodo for ouroboric-dev, and change this
  Claude project's repository to `ouroboric-dev/picasso` (quickstart §2).
  **Check**: an agent can open a PR on `ouroboric-dev/picasso`. **Depends**: T002.
- [ ] T004 [P] [US2] [owner] Point every local clone at the new remote (quickstart §3).
  **Check**: `git remote -v` names `ouroboric-dev/picasso`. **Depends**: T002.

## Phase 2: Foundational (only if the transfer slips)

- [ ] T006 [US1] [agent] *Only if T002 is more than a few days away:* make an interim sweep of the
  `uses:` lines from `h0ffmann/nix-config` to `h0ffmann/picasso` in the four consumers, so their
  Actions stop failing after the rename. Same files as T020–T030, `uses:` lines only.
  **Check**: `cv.yml` and `pubs.yml` runs are green. **Depends**: none.

**Checkpoint**: picasso is at `ouroboric-dev/picasso`, and agents can reach it.

## Phase 3: picasso itself (US2, US3), one PR on `chore/move-to-ouroboric-dev`

- [ ] T010 [US2] [agent] Change the lab reuse blocks to `github:ouroboric-dev/picasso?dir=labs/<lab>`:
  `labs/publisher/README.md:54,117`, `labs/lint/README.md:17`, `labs/agentic/README.md:88`,
  `labs/cuda/README.md:22`, `labs/present/README.md:70`, `labs/pratico/README.md:86`,
  `labs/publisher/action.yml:3`.
  **Check**: `git grep -n "h0ffmann/picasso" labs/` is empty, and `nix flake check` passes per lab
  (CI). **Depends**: T002.
- [ ] T011 [US2] [agent] Change `labs/pratico/scripts/ww-lab-submodule.sh:19` to
  `git@github.com:ouroboric-dev/picasso.git` (it still says `nix-config`).
  **Check**: `shellcheck` and the script's `--self-test` pass. **Depends**: T002.
- [ ] T012 [US3] [agent] Change `.zenodo.json:41` and `scripts/citation.py:36` to
  `https://github.com/ouroboric-dev/picasso`, then run `just citation` to regenerate
  `CITATION.cff`.
  **Check**: `citation.yml` is green, and `CITATION.cff:25-26` name the org. **Depends**: T002.
- [ ] T013 [US2] [agent] Update `README.md` (lines 12, 42, 80, 183, 324–404, 422, 428, 449–452),
  `DESCRIPTION.md:12-14`, `TAGS.md:32`, `.github/ISSUE_TEMPLATE/config.yml:4`, and the caller
  example at `.github/workflows/profile-ping.yml:14`.
  **Check**: `nix run nixpkgs#actionlint` passes, and the README badge renders. **Depends**: T002.
- [ ] T014 [US4] [agent] Change `site/history.py:12` and the links at `site/index.html:29,67,78,142`,
  then regenerate `site/history.json` from a full clone (`python3 site/history.py`).
  **Check**: `python3 site/check.py` passes. The JSON diff only changes URLs plus any commits
  merged since the last refresh. **Depends**: T002, and no other open PR changing `site/` (#85's).
- [ ] T015 [US2] [agent] Update `AGENTS.md`. Line 8 records the move ("transferred to ouroboric-dev
  on <date>"), and line 123 uses the org URL. Add `h0ffmann/picasso` and `h0ffmann/nix-config` as
  names that must never be created again. Update the consumer table to say ww3-gpu (formerly
  ww-lab).
  **Check**: a reviewer reads the diff. **Depends**: T002.
- [ ] T016 [US2] [agent] Commit as `chore: move to ouroboric-dev/picasso` with `Tested:` naming the
  CI run, and open the PR. The body says that consumers move in their own PRs (phase 4).
  **Check**: CI is green, and `git grep -nE "h0ffmann/(nix-config|picasso)" -- ':!.claude' ':!docs/adr' ':!specs'`
  returns only `configuration.nix:407` and `justfile:64`, which are local paths.
  **Depends**: T010–T015.

## Phase 4: User Story 1, consumers keep building (P1), one PR per repository

All five can run in parallel once T002 is done. They do not need phase 3.

- [ ] T020 [P] [US1] [agent] **h0ffmann/h0ffmann**: in `flake.nix:4`, use
  `github:ouroboric-dev/picasso?dir=labs/publisher` and run `nix flake update publisher`. In
  `.github/workflows/cv.yml:32`, use `ouroboric-dev/picasso/labs/publisher@main`. Leave
  `cv/test_prepare.py:55` alone (it is a fixture string) and leave `docs/superpowers/**` alone
  (dated records).
  **Check**: `python3 -m unittest discover -s cv` passes, `nix build` passes, and the next `cv.yml`
  run commits the PDFs and is still one page per language. **Depends**: T002.
- [ ] T022 [P] [US1] [agent] **h0ffmann/ww3-gpu**: in `.gitmodules:3` and
  `scripts/ww-lab-tool-setup.sh:19`, use `git@github.com:ouroboric-dev/picasso.git`, then run
  `git submodule sync`. In `flake.nix:7`, move `publisher` and run `nix flake update publisher`.
  In `.github/workflows/pubs.yml:24` and `profile-activity.yml:16`, use `ouroboric-dev/picasso/…`.
  Also update the doc links at `docs/TOOLCHAIN.md:4`, `pubs/README.md:23`, `docs/GLOSSARY.md:466`
  and `.claude/commands/update-sub-modules.md:14`.
  **Check**: `git submodule update --init` fetches `labs/pratico`, `pubs.yml` is green, and the
  submodule pin's commit is unchanged. **Depends**: T002.
- [ ] T024 [P] [US1] [agent] **h0ffmann/gcp-agentic-architect**: in `flake.nix:7,10,14`, move
  `publisher`, `lint` and `agentic`, then run `nix flake update publisher lint agentic`. In
  `.github/workflows/pubs.yml:24` and `profile-activity.yml:16`, use the org path. Update the doc
  links at `README.md:23,76,94,96,97,140,157`, `AGENTS.md:15` and `justfile:67`.
  **Check**: CI is green, and `pubs.yml` builds the book. **Depends**: T002.
- [ ] T030 [P] [US1] [agent] **marola-dev/marola**, *blocked until a person files the issue and
  labels it `agent-ready`*: in `flake.nix:9,13`, use `github:ouroboric-dev/picasso?dir=labs/lint`
  and `github:ouroboric-dev/picasso/labs/agentic?dir=labs/agentic`, then run
  `nix flake update lint agentic`. In `.github/workflows/profile-activity.yml:16`, use the org
  path. Update the comment at `flake.nix:7`, `justfile:326` and
  `docs/3-Ways-of-working/PHILOSOPHY.md:140`. Leave the MIPs alone. Open the PR with `just pr`.
  **Check**: `just quality` passes, and `nix develop` resolves the lint tools. **Depends**: T002
  and the `agent-ready` label.
- [ ] T032 [P] [US1] [agent] **marola-dev/marola-skills**: add `"ouroboric-dev"` to `own` in
  `data/sources.json`, so picasso's `.claude/skills/` stay in the index. Needs an `agent-ready`
  issue, as marola does.
  **Check**: `just quality` passes, and after `just refresh` the index lists
  `ouroboric-dev/picasso:.claude/skills/…`. **Depends**: T002 and the `agent-ready` label.

**Checkpoint**: SC-001 and SC-002 hold. The consumers build without any redirect.

## Phase 5: User Story 3, the first citable release (P2)

- [ ] T040 [US3] [owner] Turn on Zenodo for `ouroboric-dev/picasso` (quickstart §5.1).
  **Check**: the repo is listed as on at `zenodo.org/account/settings/github`. **Depends**: T003,
  and T016 merged.
- [ ] T041 [US3] [owner] Tag and release `v0.1.0`.
  **Check**: the Zenodo record exists and names the org URL (SC-004). **Depends**: T040.
- [ ] T042 [US3] [agent] Set `CONCEPT_DOI` in `scripts/citation.py:34`, run `just citation`, and
  add the DOI badge to the README. Never add `doi` to `.zenodo.json` (`AGENTS.md`).
  **Check**: `citation.yml` is green. **Depends**: T041.

## Phase 6: User Story 4, the site under the org (P3)

- [ ] T050 [US4] [owner] Settle #85 against `ouroboric-dev/picasso`. For GitHub Pages with the
  custom domain, verify the domain on the org first (quickstart §6).
  **Check**: #85's "Done when" list. **Depends**: T002, T003.

## Phase 7: Polish

- [ ] T060 [agent] Re-run the grep across all six repositories and record the result in this file.
  **Check**: SC-001. **Depends**: T016, T020–T032.
- [ ] T061 [agent] Set ADR 0001 and this spec's `status` to `implemented`, and tick the matching
  boxes in #79.
  **Depends**: T060, T041.
- [ ] T062 [owner] Pin `ouroboric-dev/picasso` on the profile (quickstart §7). **Depends**: T002.

## Dependencies and execution order

```text
T001 ─► T002 ─┬─► T003 ─► T040 ─► T041 ─► T042
              │                ▲
              ├─► T010…T015 ─► T016 ─┘
              ├─► T020 ∥ T022 ∥ T024 ∥ T030* ∥ T032*  (*after agent-ready)
              ├─► T004, T050, T062
              └─────────────────────────────► T060 ─► T061
T006 only if T002 slips
```

- The owner's critical path is T001 → T002 → T003. After it, every agent task can start at once.
- The release (T040–T041) waits for picasso's own PR (T016) and for nothing else.
- Do not change `site/` (T014) while another PR for #85 is open on it. Rebase T014 after that PR
  instead.
