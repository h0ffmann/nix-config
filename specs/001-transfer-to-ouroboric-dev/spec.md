---
title: "Feature specification: transfer picasso to ouroboric-dev"
status: draft
date: 2026-10-12
related: [plan.md, tasks.md, research.md, quickstart.md, ../../docs/adr/0001-donate-picasso-to-ouroboric-dev.md]
---

# Feature Specification: Transfer picasso to ouroboric-dev

**Feature Branch**: `001-transfer-to-ouroboric-dev` (work lands on per-repo PR branches; see [plan.md](plan.md))
**Created**: 2026-10-12
**Status**: Draft
**Input**: "Register an ADR, with a complete Spec Kit, on how to donate [picasso] to ouroboric-dev
(org move)." The decision is [ADR 0001](../../docs/adr/0001-donate-picasso-to-ouroboric-dev.md).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consumers keep building after the move (Priority: P1)

A maintainer of a repository that borrows a lab (h0ffmann/h0ffmann, ww3-gpu,
gcp-agentic-architect, marola) pushes to `main` after picasso has moved. CI resolves the flake
inputs, the composite Action and the reusable workflow from `ouroboric-dev/picasso`, and the build
passes. It must not depend on a redirect from either old name.

**Why this priority**: the labs exist to be borrowed. A move that breaks the CV build, the
publications build or marola's dev shell costs more than the move gains.

**Independent Test**: in each consumer, `git grep -nE "h0ffmann/(nix-config|picasso)"` outside
dated records returns nothing, and CI on `main` is green. Then
`nix flake metadata --json | jq '.locks.nodes[] | .locked | select(.repo=="picasso") | .owner'` is
`"ouroboric-dev"` for every picasso input.

**Acceptance Scenarios**:

1. **Given** picasso has been transferred, **When** h0ffmann/h0ffmann's `cv.yml` runs, **Then** it
   uses `ouroboric-dev/picasso/labs/publisher@main` and commits the CV PDFs.
2. **Given** a consumer's `flake.lock` names `h0ffmann/nix-config`, **When** its URL is moved and
   `nix flake update <input>` is run, **Then** the lock names `ouroboric-dev/picasso`, and
   `nix flake check --no-update-lock-file` passes.
3. **Given** ww3-gpu has the sparse submodule, **When** `.gitmodules` is moved and
   `git submodule sync && git submodule update` is run, **Then** `nix-config/labs/pratico` is
   checked out from the org URL.
4. **Given** a merged PR in marola, **When** `profile-activity.yml` runs, **Then** it calls
   `ouroboric-dev/picasso/.github/workflows/profile-ping.yml@main` and the dispatch reaches the
   profile.

---

### User Story 2 - The owner moves the repository in one sitting (Priority: P1)

The owner follows [quickstart.md](quickstart.md), from the org checks to the last consumer merge.
They never have to guess which step comes next or which setting to open, and no step needs an agent
to act on their account.

**Why this priority**: the transfer, the app approvals and the Zenodo switch can only be done by
the owner. Everything else waits on them.

**Independent Test**: someone with no context reads quickstart.md and can name, for each step,
where to click or what to type, and how to check it worked.

**Acceptance Scenarios**:

1. **Given** the owner is an org owner of ouroboric-dev, **When** they transfer
   `h0ffmann/picasso`, **Then** `https://github.com/ouroboric-dev/picasso` shows every issue and PR,
   all stars and the full history.
2. **Given** the transfer is done, **When** they open the org's third-party access page, **Then**
   the Claude GitHub App and Zenodo are approved for `ouroboric-dev`.

---

### User Story 3 - The first citable release carries the final URL (Priority: P2)

A reader cites picasso from Zenodo. Every version's metadata names
`https://github.com/ouroboric-dev/picasso`, from v0.1.0 on.

**Why this priority**: a Zenodo version cannot be edited after it is published. Getting this wrong
is permanent, but nothing is lost by waiting.

**Independent Test**: `jq -r '.related_identifiers[0].identifier' .zenodo.json` and
`yq .repository-code CITATION.cff` both print the org URL, and `citation.yml` is green. The v0.1.0
record on Zenodo shows that URL.

**Acceptance Scenarios**:

1. **Given** no tag exists, **When** the Zenodo integration is turned on, **Then** it is turned on
   for `ouroboric-dev/picasso`, not the personal account.
2. **Given** the citation files name the org URL, **When** `v0.1.0` is tagged, **Then** Zenodo
   mints a concept DOI, and the DOI is added to `CITATION.cff` and the README in a follow-up PR.

---

### User Story 4 - The site and its domain land under the org (Priority: P3)

The hosting chosen in #85 is set up once, against `ouroboric-dev/picasso`. The official link does
not change after it is published.

**Why this priority**: the site has no public URL yet, so nothing breaks today. It only matters
that #85 is not set up twice.

**Independent Test**: the URL chosen in #85 serves `site/` with a valid certificate, and a push to
`main` that touches `site/` is live without a manual upload.

**Acceptance Scenarios**:

1. **Given** #85 picks GitHub Pages with a custom domain, **When** it is set up, **Then** the domain
   is verified on ouroboric-dev and Pages publishes from `ouroboric-dev/picasso`.

---

### Edge Cases

- **Someone creates `h0ffmann/picasso` or `h0ffmann/nix-config` again** (for example, a fork back to
  the personal account). Every redirect from that name stops. This is why no reference may rely on
  one, and why `AGENTS.md` lists both names as reserved.
- **A consumer with an allowed-actions policy.** An org that allows only listed actions refuses
  `ouroboric-dev/picasso/*` until it is added. marola-dev's setting has to be checked.
- **The transfer waits for days.** The `uses: h0ffmann/nix-config/…` lines are likely broken since
  the rename, so make the interim sweep to `h0ffmann/picasso` (ADR 0001).
- **Open PRs at transfer time** (for example, #60). PRs move with the repository. Their head
  branches are in the same repository, so they move too. Local clones keep pushing through the git
  redirect until `git remote set-url` is run.
- **marola's `agentic` input follows the branch `labs/agentic`.** Branches move with the
  repository. The ref stays the same and only the owner changes.
- **Zenodo turned on too early.** If the integration is enabled before the transfer, its webhook
  and record may stay tied to the old owner (inferred, not tested). Turn it off and on again after
  the transfer, before any tag.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST be moved with GitHub's transfer (not re-created or forked), keeping
  its name `picasso`, issues, PRs, stars and history.
- **FR-002**: Only the owner performs the transfer and the account-level steps (app approvals, Zenodo,
  DNS). Agents MUST NOT perform them.
- **FR-003**: Every flake input in a consumer MUST name `github:ouroboric-dev/picasso`, and its
  `flake.lock` MUST be re-recorded in the same PR.
- **FR-004**: Every `uses:` line that names a picasso Action or reusable workflow MUST name
  `ouroboric-dev/picasso`.
- **FR-005**: Every submodule URL for picasso MUST name `ouroboric-dev/picasso`. Submodule
  directories (`nix-config/`) MAY keep their names.
- **FR-006**: `.zenodo.json`, `scripts/citation.py` and the generated `CITATION.cff` MUST name
  `https://github.com/ouroboric-dev/picasso` before the Zenodo integration is turned on, and the
  integration MUST be turned on before the first tag.
- **FR-007**: Inside picasso, every non-dated reference listed in [research.md](research.md) R3 MUST
  name the org. `site/history.json` MUST be regenerated, never hand-edited.
- **FR-008**: `AGENTS.md` MUST record the move and list `h0ffmann/picasso` and `h0ffmann/nix-config`
  as names that must never be created again.
- **FR-009**: Dated records (MIPs, `docs/superpowers/**`, journal entries, this spec once accepted)
  MUST NOT be rewritten.
- **FR-010**: Hosting (#85) MUST be set up against `ouroboric-dev/picasso`, with any custom domain
  verified on the org.
- **FR-011**: marola-skills' `data/sources.json` MUST list `ouroboric-dev` under `own`, so picasso's
  vendored skills stay in the index.
- **FR-012**: `LICENSE` and the creators in `.zenodo.json` MUST NOT change as part of the move.

### Key Entities

- **Reference**: a place that names the repository: a repo, a `file:line`, and a kind (flake input,
  lock node, submodule URL, `uses:` line, metadata URL, doc link). It is either *resolving* (CI or
  Nix follows it) or *descriptive* (a person follows it).
- **Consumer**: a repository with at least one resolving reference: h0ffmann/h0ffmann, ww3-gpu,
  gcp-agentic-architect, marola. marola-skills is an index, not a consumer.
- **Owner step**: a step only the account owner can take, listed in [quickstart.md](quickstart.md).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `git grep -nE "h0ffmann/(nix-config|picasso)"` returns 0 resolving references across
  picasso and the four consumers, outside dated records.
- **SC-002**: CI on `main` is green in picasso and all four consumers on the first run after their
  PR merges.
- **SC-003**: `ouroboric-dev/picasso` has the same number of issues, PRs and stars as
  `h0ffmann/picasso` had just before the transfer.
- **SC-004**: Zenodo v0.1.0 lists `https://github.com/ouroboric-dev/picasso`, and no Zenodo version
  of picasso names `h0ffmann`.
- **SC-005**: From the transfer to the last consumer merge, no consumer's `main` stays red because
  of the move.

## Assumptions

- The owner is an owner of ouroboric-dev, so they can create repositories there and approve apps.
- The name `picasso` is free in ouroboric-dev (it was on 2026-10-12: the org has five repositories
  and none of them is called `picasso`).
- picasso stays public and MIT. The open licence questions are in ADR 0001.
