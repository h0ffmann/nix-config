# Architecture decision records

One file per decision, numbered `NNNN-<slug>.md`, never renumbered. A record is not edited after it
is accepted: a later decision supersedes it with a new record, and the old one's `status` becomes
`superseded`.

Front matter and the `**Decided YYYY-MM-DD:**` line follow ouroboric-dev's
[docs standard](https://github.com/ouroboric-dev/ouroboric/blob/main/docs/4-ways-of-working/docs-standard.md#5-conventions),
so a record reads the same here and in the org. The work a decision starts lives in
[`specs/`](../../specs/), in [Spec Kit](https://github.com/github/spec-kit)'s layout
(`spec.md`, `plan.md`, `tasks.md`, plus `research.md` and `quickstart.md` when they earn their place).

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-donate-picasso-to-ouroboric-dev.md) | Donate picasso to ouroboric-dev by a GitHub repository transfer | draft |
