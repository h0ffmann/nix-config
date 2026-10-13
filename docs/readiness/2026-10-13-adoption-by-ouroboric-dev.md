---
title: Ready for adoption by ouroboric-dev — assessment 2026-10-13
status: draft
date: 2026-10-13
related: [../rea/2026-10-13-ouroboric-dev.md, "https://github.com/ouroboric-dev/asgard/blob/1acab205610d3c9d816076bf83baa0b333c4dd08/templates/readiness/checklist.md", "https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/docs/1-company/readiness/2026-10-11-ready-to-build.md"]
style: direction
---

# Ready for adoption by ouroboric-dev — assessment 2026-10-13

**Bottom line: picasso does not pass level 1 ("ready to build") of the ouroboric-dev readiness
checklist.** Of 21 items, 2 are met, 14 are partial, 4 are missing and 1 is not applicable. The
labs, their checks and the release path work. The open items are mostly records and decisions:
a charter, a roadmap, a journal, the shape of `AGENTS.md`, and the owner's statements.

An agent made this assessment. The human did not review it yet.

## What "adoption" means here

The ouroboric-dev repositories define three readiness levels. They do not define "adoption" of a
repository from outside the organisation, and they do not name picasso. A search
(`git grep -iE 'picasso|graduat|\badopt'`) in the 11 repositories, at the commits in the
[REA report](../rea/2026-10-13-ouroboric-dev.md), shows this: `picasso` and `graduat` are in no
file, and `adopt` is only in licence texts, in the journal and in research notes about other
tools.

- The levels: "The company's **readiness levels** gate what follows: *ready to build* before the
  first spec, *ready to launch* before `deploy-prod`, *ready to promote* before public promotion."
  ([spec-driven-development.md, lines 66-67](https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/docs/4-ways-of-working/spec-driven-development.md#L66-L67))
- The evidence rule: "Give evidence (a link) for each item, or mark the item missing."
  ([checklist.md, line 14](https://github.com/ouroboric-dev/asgard/blob/1acab205610d3c9d816076bf83baa0b333c4dd08/templates/readiness/checklist.md#L14))
- Who decides: "Humans steer. Stop and ask when work would leave an approved charter, spec or
  plan." ([AGENTS.md, line 11](https://github.com/ouroboric-dev/ouroboric/blob/b355b1d52d6906f80447fe84283f705403533d0b/AGENTS.md#L11))

Thus this document does two things. It measures picasso against level 1 of the checklist, as a
product that ouroboric-dev could take in. Then it lists the facts that a decision to use a
picasso lab needs. The decision belongs to the ouroboric-dev operators.

Levels 2 and 3 are not assessed. Each level is a gate for the next one, and level 1 is not
passed.

## Summary

| Status | Count | Items |
|---|---|---|
| met | 2 | RB-08, RB-16 |
| partial | 14 | RB-02, RB-04, RB-05, RB-06, RB-07, RB-09, RB-11, RB-12, RB-13, RB-14, RB-15, RB-19, RB-20, RB-21 |
| missing | 4 | RB-03, RB-10, RB-17, RB-18 |
| n/a | 1 | RB-01 |

For comparison, the assessment of ouroboric-dev itself at `b355b1d` gives 14 met, 5 partial and
2 missing, and its bottom line is "not ready to build yet".

## Items

The item ids are those of the checklist at asgard `1acab20`. The questions are in picasso's own
words. Evidence is a file at `9c7f99f`, or a command that was run on 2026-10-13 with its result.

| ID | Question | Status | Evidence | To close |
|---|---|---|---|---|
| RB-01 | Company charter accepted? | n/a | picasso is one person's repository and has no company umbrella. The Ouroboric charter at `b355b1d` does not name picasso. | — |
| RB-02 | Product charter accepted and conforming? | partial | [`PHILOSOPHY.md`](../../PHILOSOPHY.md) and [`DESCRIPTION.md`](../../DESCRIPTION.md) give the purpose and the reasons. There is no charter with a status, north-star measures and boundaries. Conformance with the Ouroboric charter is not checked; that charter's Focus boundary is "Yggdrasil and Asgard before any new factory". | the human writes and accepts a charter; the ouroboric-dev operators check conformance |
| RB-03 | Design document of milestone 1 accepted? | missing | no design document. [`docs/adr/`](../adr/README.md) has one record, with status Proposed, about posts to Threads. | the human, if picasso takes the design-document step |
| RB-04 | Roadmap written? | partial | the goals are issues with the label `type/goal` (#66, #82, #95, #100, #104). There is no roadmap file. | a roadmap file that puts the goals in order |
| RB-05 | Principles as `AGENTS.md` invariants? | partial | [`AGENTS.md`](../../AGENTS.md) has hard rules (`grep -c 'hard rule' AGENTS.md` gives 5). The shape that `ouroboric/scripts/check-repos.sh` checks is absent: `grep -c '^## Invariants' AGENTS.md` gives 0. | the human: `AGENTS.md` is a reserved file |
| RB-06 | Name checked? | partial | the README's License section says that "Picasso" names the repository only. #79 (the name before the first Zenodo release) is open. No check of domains, registries or trademarks is recorded. | the human does the check and records it |
| RB-07 | Brand seed written? | partial | the logo in [`docs/media/`](../media/) and the drawings rule in `AGENTS.md`. No document gives the story or the naming rules. | a short story and naming document |
| RB-08 | Licence chosen for all public files? | met | [`LICENSE`](../../LICENSE), [`REUSE.toml`](../../REUSE.toml). `reuse lint` on this branch: "Congratulations! Your project is compliant with version 3.3 of the REUSE Specification". CI job `licences (REUSE)`: success on `9c7f99f`. | — |
| RB-09 | Contribution terms in place? | partial | GitHub shows a code of conduct and a contributing guide from `h0ffmann/.github`. That repository is a fork of `ouroboric-dev/.github` with no changes, so the guide speaks about Ouroboric. Private vulnerability reporting is off (`gh api repos/h0ffmann/picasso/private-vulnerability-reporting` gives `{"enabled":false}`). No contributor agreement or DCO. | the human: own text, the setting, and the agreement |
| RB-10 | Ownership clear? | missing | no statement from the owner is recorded. An agent cannot judge this item. | the human confirms |
| RB-11 | Shape decided? | partial | one public repository of labs; `https://h0ffmann.github.io/picasso/` gave HTTP 200 on 2026-10-13. The own domain is open (#85). No record says if picasso stays personal or moves to an organisation. | the human decides |
| RB-12 | Repository exists and follows the docs standard? | partial | the repository exists and its ruleset `main-protect` is active. Differences from the standard: `docs/` is not the numbered tree, `AGENTS.md` has 327 lines (the standard gives about 100 to a leaf), there is no `docs/architecture.md`, and the settings allow merge commits and rebase merges, issues and the wiki. | the human decides which differences stay |
| RB-13 | Budgets and caps set? | partial | no lab needs a paid service, and CI uses GitHub's runners for public repositories. The skill benchmark needs about 3 USD for each full run (#116) and no cap is recorded. | record a cap for the benchmark |
| RB-14 | Dedicated credentials, no secrets, secret scanning? | partial | secret scanning and push protection are enabled (`gh api repos/h0ffmann/picasso`, `security_and_analysis`). `.env` is in `.gitignore`, and `AGENTS.md` (Safety) forbids a committed token. No pinned gitleaks hook. No scan of the full history is recorded, and this assessment did not run one. | a gitleaks hook and one recorded scan of the history |
| RB-15 | Standards accepted? | partial | `AGENTS.md` is the accepted standard: the lab contract, the commit format and ASD-STE100 for prose. The four ouroboric-dev standards are not accepted here; this pull request borrows only the front matter and the dated file names. | the human decides which standards picasso takes |
| RB-16 | Research recorded? | met | [`WHITEPAPER.md`](../../WHITEPAPER.md) with its references, [`docs/studies/determinate-2026/`](../studies/determinate-2026/README.md), [`notes/`](../../notes/). | — |
| RB-17 | Journal started? | missing | no journal. `site/static/history.json` is the commit history, not a record of challenges and results. | the human decides; then one entry for each challenge |
| RB-18 | Implementation plan accepted? | missing | no plan with tasks. `WHITEPAPER.md` §6 has five proposals (P1 to P5) for ouroboric-dev; they are proposals, and none is accepted. | a plan, after the two sides agree on a proposal |
| RB-19 | Technical risks identified, tested first? | partial | `WHITEPAPER.md` §8 lists the limits, and §7 is a plan of three measurements. No measurement of §7 is recorded. | do the first measurement of §7 |
| RB-20 | Measure of success fixed in advance? | partial | for a lab change: the CI gate in `AGENTS.md` ("Definition of done"). For the proposals to ouroboric-dev: the success conditions in `WHITEPAPER.md` §7. No frozen brief or hidden tests. | fix the measure with the ouroboric-dev operators |
| RB-21 | Minimal visual identity defined? | partial | the logo in light and dark versions and the social preview in `docs/media/`; the README's License table gives the site's fonts and their licence. No recorded palette with a contrast check. | a short identity document |

## Facts for a decision to use a lab

These facts are not checklist items. Each has the command or the file that shows it.

| # | Fact | Evidence |
|---|---|---|
| A1 | No ouroboric-dev repository uses Nix today. | `git ls-files` in the 11 clones: 0 files with the name `*.nix` or `flake.lock`. Six component repositories have a `.devcontainer/devcontainer.json`. |
| A2 | The ouroboric-dev components are scaffolds. | `git ls-files` in the 11 clones: 0 files with the name `*.go`, 0 workflow files. Thus no picasso lab has a build there to supply. |
| A3 | The lab that `WHITEPAPER.md` §6 proposes for ouroboric-dev (`labs/factory`, P1) does not exist. | `ls labs`: agentic, cuda, gleam-website, lint, paper, pratico, present, publisher, viz. |
| A4 | picasso's code licence and Ouroboric's factory-code licence are the same, AGPL-3.0-only. | [`REUSE.toml`](../../REUSE.toml); ouroboric `docs/1-company/legal/README.md` at `b355b1d`. Analysis, not legal advice: Ouroboric plans a contributor licence agreement so that it can give its code under more than one licence. A lab that Ouroboric copies stays under Matheus Hoffmann's copyright and AGPL-3.0-only unless the two owners agree on other terms. A lab that Ouroboric pins as a flake input is not copied. |
| A5 | `WHITEPAPER.md` §8 says "picasso is a personal repository under MIT". That is true only for releases up to v0.1.1. | [`WHITEPAPER.md`](../../WHITEPAPER.md), line 216; README, License section. A correction needs the two PDFs to be rendered again (`AGENTS.md`, Releases), so it is not in this pull request. |
| A6 | A repository outside the labs' first consumers pins two labs today. | `h0ffmann/closed-source` at `6d91573`, `flake.nix`: inputs `github:h0ffmann/picasso?dir=labs/paper` and `?dir=labs/gleam-website`. The other consumers in the `AGENTS.md` table were not checked for this assessment. |
| A7 | `main` is green. | `gh api repos/h0ffmann/picasso/commits/main/check-runs`: 16 check runs, all `success`, on `9c7f99f`. |
| A8 | The next release is ready, and it is the first one under AGPL-3.0-only and CC BY 4.0. | `bash scripts/release.sh minor --dry-run` on a clean `main` at `9c7f99f`: "release: v0.2.0 at 9c7f99f", no tag made. Only the human makes the tag. |
| A9 | The ouroboric-dev repositories do not take pull requests from outside now. | `.github` at `b799793`, `CONTRIBUTING.md`: "Ouroboric is read-only for now". Thus this assessment is in picasso, and a request to ouroboric-dev goes through an `[A2A]` issue (`AGENTS.md`, "Messages between Claude projects"). |

## Proposed order

1. The human reviews this assessment and the [REA report](../rea/2026-10-13-ouroboric-dev.md).
2. The human decides RB-10 and RB-11, and tags v0.2.0 if the release is wanted (A8).
3. The two owners agree on one proposal from `WHITEPAPER.md` §6 and on the terms in A4.
4. Then the records follow: a charter (RB-02), a roadmap (RB-04) and a plan (RB-18).

## Credit

The item ids, the three levels and the layout of this document are borrowed from
ouroboric-dev/asgard@1acab20 (MIT) and ouroboric-dev/ouroboric@b355b1d (CC-BY-4.0), © 2026 Bruno
Guilhermo de Barros Valério. No text was copied; the short quotations are marked, and each names
its source. The front matter follows the Ouroboric documentation standard at the same commit.
