# Philosophy

[AGENTS.md](AGENTS.md) holds the rules; this page holds the reasons. It follows
marola-dev/marola's own PHILOSOPHY page, which explains the same habits for the project that
borrows most from this one.

## The one decision

**A toolchain is a dependency, so pin it like one.** A wave model that compiled last year and does
not compile today has lost its results with it: the paper's numbers can no longer be reproduced
from the paper's code. Everything here follows from treating gfortran, OpenMPI, NetCDF, TeX Live,
CUDA and the agent tooling as inputs with a version, a lock and a check, instead of things a
machine happens to have installed.

## Why labs, and why they share nothing

A lab is a directory that references nothing outside itself. That costs duplication, and it is
paid on purpose: it is what lets WW3 GPU Lab check out `labs/pratico` alone as a sparse
submodule, and marola pin `?dir=labs/lint` without pulling the rest. A shared `lib/` would remove
some copies and make every consumer depend on the whole repository. Copying wins.

Every lab exports the same shape (`devShells`, `lib.<system>.tools`, `packages`, `checks`), so a
consumer that learnt one has learnt all of them.

## Why CI fails instead of warning

A lock that is behind its flake fails CI rather than printing a warning, because a warning on a
green build is read by nobody. Every `checks.*` output must build in the Nix sandbox, and every
script carries a `--self-test` that fakes the commands it calls, so the gate runs the code rather
than trusting that it would run.

## Why nothing touches the host on its own

The repo configures a real machine. Anything that writes `/etc/nix`, restarts the daemon or
collects garbage is proposed with a dry run and waits for a person. An agent working here is
useful because it is fast, and the same speed makes an unreviewed change to a workstation
expensive. `labs/agentic` exists for the same reason: the agent runs in a sandbox that limits what
it can reach, and the rules above still apply inside it.

## Why the layout is borrowed

The README-as-catalogue, one `<details>` table per environment and `notes/` for things worth
writing down once all come from gvolpe/nix-config, and are credited there. Borrowing a layout that
already works leaves the effort for the labs.

## Why the name

The repository started as `nix-config` and grew into something else: a set of labs other projects
build on. Picasso drew a whole animal with one unbroken line; a lab tries to describe a whole
toolchain with one flake. The name is a homage and claims no affiliation with the Picasso estate.
