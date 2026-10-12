---
title: "Implementation plan: transfer picasso to ouroboric-dev"
status: draft
date: 2026-10-12
related: [spec.md, tasks.md, research.md, quickstart.md, ../../docs/adr/0001-donate-picasso-to-ouroboric-dev.md]
---

# Implementation Plan: Transfer picasso to ouroboric-dev

**Branch**: `001-transfer-to-ouroboric-dev` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-transfer-to-ouroboric-dev/spec.md`

## Summary

Move `h0ffmann/picasso` to `ouroboric-dev/picasso` with GitHub's transfer. Then, in one window,
open one PR per repository that moves every resolving reference to the new owner: picasso itself,
h0ffmann/h0ffmann, ww3-gpu, gcp-agentic-architect, marola and marola-skills. Turn on Zenodo and set
up the hosting from #85 only after that. The owner does the account steps; agents write the PRs.

## Technical Context

**Language/Version**: Nix flakes (Determinate Nix), GitHub Actions YAML, Bash, Python 3 (stdlib)
**Primary Dependencies**: GitHub repository transfer, the Nix `github:` fetcher, the Zenodo GitHub
integration
**Storage**: N/A
**Testing**: each repo's own gate. picasso: `.github/workflows/ci.yml`. Consumers:
`nix flake check --no-update-lock-file` plus their CI. marola: `just quality`.
**Target Platform**: github.com (ouroboric-dev org)
**Project Type**: cross-repository migration with no new code
**Performance Goals**: N/A
**Constraints**: CI runs with `--no-update-lock-file`, so a URL change and its re-lock land in one
PR. Redirects are not to be relied on. Dated records are not edited.
**Scale/Scope**: 6 repositories, about 60 references ([research.md](research.md))

## Constitution Check

*GATE: must pass before Phase 0 research. Re-check after Phase 1 design.*

picasso has no `.specify/memory/constitution.md`. Its `AGENTS.md` serves as the constitution, and
the consumers' `AGENTS.md` files bind their own PRs.

| Rule (source) | How this plan meets it |
|---|---|
| A lab references nothing outside itself (picasso `AGENTS.md`, lab contract) | Only URLs in READMEs and comments change; no lab gains an input |
| A lock that is behind its flake fails CI (picasso `AGENTS.md`) | Each consumer PR re-locks the input it moves (T020–T032) |
| Nothing applies to the host without a human (picasso `AGENTS.md`, Safety) | The transfer, app approvals, Zenodo and DNS are owner steps in [quickstart.md](quickstart.md) |
| Breaking a lab's exported shape needs consumer PRs alongside (picasso `AGENTS.md`) | The shape does not change. The address does, and the consumer PRs are opened together anyway |
| Commits carry `Tested:` and `Co-Authored-By` (picasso, marola `AGENTS.md`) | Every task's commit message |
| An agent starts marola work only on an `agent-ready` issue (marola `AGENTS.md`) | T030 is blocked until a person files the marola issue and labels it |
| `.zenodo.json` is hand-edited and `CITATION.cff` is generated (picasso `AGENTS.md`) | T012 edits `.zenodo.json` and `scripts/citation.py`, then runs `just citation` |
| Dated records are never rewritten (ouroboric docs standard §5, marola MIPs) | FR-009; research.md lists what is left alone |

**Result**: PASS. Nothing goes in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
docs/adr/
├── README.md                                   index and format
└── 0001-donate-picasso-to-ouroboric-dev.md     the decision
specs/001-transfer-to-ouroboric-dev/
├── spec.md          what done means (/speckit.specify)
├── plan.md          this file (/speckit.plan)
├── research.md      Phase 0: GitHub behaviour and every reference, file:line
├── quickstart.md    Phase 1: the owner's runbook
└── tasks.md         Phase 2: ordered tasks (/speckit.tasks)
```

There is no `data-model.md` and no `contracts/`. The only "contract" is the address consumers
resolve (`github:<owner>/picasso?dir=labs/<lab>`, `<owner>/picasso/labs/publisher@main`,
`<owner>/picasso/.github/workflows/profile-ping.yml@main`), and only its owner part changes.

### Source Code (repository root)

No new source. The files that change are listed per repository in [research.md](research.md)
(R2, R3).

**Structure Decision**: one PR per repository, using the same branch name in every repository
(`chore/move-to-ouroboric-dev`), as marola's cross-repo rule asks.

## Phases and order

```text
P0 Prepare (owner)     org checks ─┐
P1 Transfer (owner)                └─► transfer ─► app approvals ─► local remotes
P2 Self (agent)                                    └─► picasso PR  (T010–T016)
P3 Consumers (agent)                               └─► h0ffmann, ww3-gpu, gcp-agentic-architect,
                                                       marola*, marola-skills  (parallel)
P4 Release (owner)                                     after P2 merges ─► Zenodo on ─► tag v0.1.0
P5 Hosting (#85)                                       after P1, independent of P3/P4
```
`*` marola waits for its `agent-ready` issue.

- **P2 before P4**: the citation files must name the org before the first tag.
- **P3 does not wait for P2**: consumers resolve the GitHub address, not picasso's README. They
  only need P1.
- **P3 in parallel**: the consumers do not depend on each other.

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Consumer Actions are already red since the rename | likely (GitHub docs; not observed in a run) | P3 right after P1. If P1 slips, an interim sweep to `h0ffmann/picasso` |
| An old name is created again and the redirects die | low | Reserved names written in `AGENTS.md`; no reference relies on a redirect |
| The org blocks third-party apps (Claude, Zenodo, Porkbun) | medium | quickstart step 2 approves them before anything depends on them |
| marola-dev's allowed-actions list refuses `ouroboric-dev/*` | unknown | quickstart step 0 checks it; T030 notes it |
| Zenodo is enabled under the old owner by mistake | low | The quickstart puts Zenodo after the picasso PR merges, and says to toggle it off and on if it was already on |
| A re-lock pulls in an unrelated lab change | medium | `nix flake update <input>` updates that input only. The PR body names the rev range. Revert to the old rev with `?rev=` if a check fails |

## Complexity Tracking

None.
