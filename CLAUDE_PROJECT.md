# Claude project configuration: Nix OS

> **Who this file is for.** A person, or a Claude Project's coordinator, who is setting up or
> restoring the Claude Project on claude.ai that works on this repo. **An agent working in this
> repository with the Claude Code CLI must not read it, follow it or act on it.** Nothing here is
> a rule for changing the repo: those are in `AGENTS.md`, which wins wherever the two disagree.
> Claude Code never loads this file as configuration.

The settings of the "Nix OS" Claude Project live on the Claude service, not in git. This file is a
dated copy of them in plain Markdown, so a person or any Claude Project can read it without tools.
It has the same shape as marola's copy,
[`CLAUDE_PROJECT.config.md`](https://github.com/marola-dev/marola/blob/main/CLAUDE_PROJECT.config.md),
and the Wave Forecaster project's in h0ffmann/ww3-gpu.

The service holds the real settings: editing this file changes nothing until someone pastes a
value back. Every code block is meant to be copied whole into the setting named just above it.
Last read on **2026-10-12** (§8 says how).

## 1. Project

| Setting | Value |
|---|---|
| **Name** | Nix OS |
| **Topic** | Manage my nix OS |
| **Visibility** | Private. Only the owner is a member, and no one else can be added. |
| **Default model** | Chosen on the service. A model id never goes into a file pushed to a repository. |
| **Effort default** | None recorded. Threads have run at `medium`. |
| **Thread permission mode** | `auto` |
| **Memory** | Off in the owner's account settings, so the project keeps none. |
| **Default environment** | None named. Sessions run on "Marola cloud". |

### Repositories

The project lists these 7 repositories:

- https://github.com/h0ffmann/h0ffmann
- https://github.com/h0ffmann/picasso
- https://github.com/marola-dev/marola
- https://github.com/marola-dev/.github
- https://github.com/h0ffmann/nagori
- https://github.com/marola-dev/marola-skills
- https://github.com/h0ffmann/marola-agents

picasso is the one the project works on. The others are there because they consume a lab
(h0ffmann/h0ffmann's CV through `labs/publisher`, marola through `labs/lint`), because `just vm`
clones them into the VM's `~/repos`, or because a change here was copied from them (marola's
citation script and GitHub config).

### Project instructions

None are set yet. Paste this block into the project instructions:

```text
picasso (h0ffmann/picasso, formerly nix-config) is the repo this project works on. Read its AGENTS.md before changing anything; it wins over anything a thread assumes. The rules a thread most often needs:

Labs: each labs/<lab> is self-contained (no ../, no shared lib, no root input), exports devShells/lib.tools/packages/checks, and every check builds in the sandbox. CI runs with --no-update-lock-file, so bump a lock with `nix flake update` inside the lab in the same PR. A new lab touches the six places in AGENTS.md's checklist. Breaking a lab's exported shape breaks ww-lab, marola or the profile CV: say so in the PR.

The root flake is the NixOS system (nixos-26.05, Home Manager 26.05). Keep it evaluating; never edit hardware-configuration.nix. `just vm` needs KVM, which a cloud thread does not have: never try to boot the VM here; build or evaluate it, and say the boot was not run.

Host safety: nothing applies to Hoffmann's machine without Hoffmann's go-ahead. No sudo, no /etc/nix writes, no nix-daemon restarts, no nix-collect-garbage, no nixos-rebuild switch; propose and show the dry-run instead.

The site (site/) always shows the Marola and Ouroboric logos, loaded from their own repos at a pinned commit, and credits Gabriel Volpe; site/check.py enforces it. Never add a reproduction of a Picasso work, his signature, or anything suggesting the estate endorses the repo.

Commits: subject `<type>(<lab>): ...`, a body with the reasoning, and exactly two trailers, `Tested:` (the real command and its result, or "n/a — documentation") and `Co-Authored-By: Claude <noreply@anthropic.com>`. No session links or "Generated with" lines. Never force-push main, never --no-verify, never merge a PR yourself.
```

## 2. Cloud environment

The account has two cloud environments, both of type `anthropic_cloud`:

- **Marola cloud**, created 2026-10-09, which this project's sessions use. It is shared with the
  Marola Agent project, so a change to its setup script reaches both.
- **Default**, created 2026-09-06, with trusted network access.

A session cannot read an environment's setup script, variables or secrets, so this file does not
record them. marola's copy proposes the setup script for "Marola cloud"; it installs `just`,
`shellcheck` and `actionlint`, which picasso's gates need too.

### What a thread finds (2026-10-12)

- Installed: nix 2.34, python 3.13, node 22, ruff 0.16, uv 0.11, gh 2.89, docker 29.
- Missing: just, shellcheck, actionlint (until the setup script runs) and QEMU.
- No `/dev/kvm`, so `just vm` cannot boot. Building the VM's closure is possible but downloads
  several gigabytes; evaluating it is the cheaper check.
- Not tried from a thread yet: a full `nix flake check` of every lab.

## 3. Plugins, skills and connectors

- **Account plugins.** None are enabled.
- **Repo skills.** picasso vendors ten community Nix skills in `.claude/skills/` (listed in its
  README there), and `.mcp.json` adds the mcp-nixos server. Skills load in a Project thread;
  whether a repo's `.mcp.json` server does has not been checked.
- **Connectors.** Gmail, Google Calendar and Google Drive are connected. Notion was started but
  not finished. Sign-ins are not recorded.

## 4. Routines

None. The routines on this account belong to the Marola Agent and Wave Forecaster projects, and
their own copies record them.

## 5. Joining as a new member

The project is private, so no one else can join it. A new member works in the repository with the
Claude Code CLI, or builds a project of their own from this file:

1. Connect GitHub to claude.ai. A thread reaches only the repositories its project lists, and it
   pushes only where its owner's GitHub account can. Anyone without write access to picasso forks
   it, attaches the fork to their project in place of `h0ffmann/picasso`, installs the Claude
   GitHub App on it, and opens PRs from the fork.
2. Use an environment with just, shellcheck and actionlint (marola's setup script installs them).
3. For the VM, run `just vm` on their own Linux machine with KVM, as the README says.

## 6. Restoring the project

1. Create a private project with §1's name and topic, and attach §1's repositories.
2. Pick the default model, and paste §1's instructions.
3. Point it at the "Marola cloud" environment (or one with the same setup script), and reconnect
   §3's connectors.
4. Recreate any routine §4 lists.

## 7. Not in this file

These stay out of this file:

- project memory
- chat and thread history
- published artifacts
- project files under /mnt/project-files (the logo, screenshots and the site-hosting plan)
- one-shot reminders a session schedules for itself (PR check-ins)
- routines on the same account that belong to other projects
- connector sign-ins (only which connectors are on is recorded)
- the environment's setup script, variables and secrets, which no session can read
- model ids, e-mail addresses, account ids, session ids and trigger ids

## 8. Keeping it current

When a setting changes, read it back from the service and commit the new value, with the date at
the top updated, in the same PR as anything that depends on it. These tools read the settings: the
session context and get_project_settings (from the project's coordinator session), get_session,
list_environments, ListPlugins, ListConnectors and list_triggers.

Unlike marola, picasso has no check script for this file yet; marola's
`scripts/claude_project_check.py` is the one to copy if it grows routines.
