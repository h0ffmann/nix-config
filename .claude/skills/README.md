# Vendored agent skills

Community skills for agentic Nix work, copied in so Claude Code (and any tool that reads
`.claude/skills/*/SKILL.md`) uses them in this repo. Each `SKILL.md` is the upstream file
with one added note under its front matter: where it came from, and what differs in this repo.
AGENTS.md wins wherever a skill disagrees with it.

| Skill | Upstream | Commit | Licence | Use it for |
|---|---|---|---|---|
| `ultimate-nixos` | [kaynetik/skills](https://github.com/kaynetik/skills) | `3ecbe1424cd5` | MIT | NixOS, Home Manager, modules, flakes, packaging, hardening |
| `nix-best-practices` | [0xbigboss/claude-code](https://github.com/0xbigboss/claude-code) | `2921eb8a685a` | Apache-2.0 | flake structure, overlays, dev shells |
| `nix-config-debug` | [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) | `497fabbf9206` | MIT | localising eval / build / activation / runtime failures |
| `nix-config-update` | [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) | `497fabbf9206` | MIT | bumping inputs as a supply-chain event, validating before deploy |
| `nixpkgs-review` | [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) | `497fabbf9206` | MIT | reviewing an upstream nixpkgs PR before relying on it |
| `nix` | [shakhzodkudratov/nixos-and-flakes-skill](https://github.com/shakhzodkudratov/nixos-and-flakes-skill) | `c9a423b2af83` | MIT | general Nix, flakes, Home Manager reference |
| `nixos-managing` | [michalzubkowicz/nixos-management-skill](https://github.com/michalzubkowicz/nixos-management-skill) | `aa1e3a3cec56` | MIT | rebuilds, installs, LUKS, VMs, images, anti-patterns |
| `nixos-usb-recovery` | [edmundmiller/dotfiles](https://github.com/edmundmiller/dotfiles) | `4a34a07dc9aa` | MIT | rescuing a NixOS install that no longer boots |
| `nix-package-patching` | [edmundmiller/dotfiles](https://github.com/edmundmiller/dotfiles) | `4a34a07dc9aa` | MIT | bumping pins and hashes, rebasing carried patches |
| `systemd-hardening` | [daracci/nix-config](https://github.com/daracci/nix-config) | `6e5c465f66b2` | MIT | sandboxing `systemd.services` written in Nix |
| `graphify` | [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify) (PyPI `graphifyy`) | `0.9.85` | Apache-2.0 | a queryable knowledge graph of a codebase (`just graphify`) |

## On demand for this repo

The skills worth asking for by name to improve this repository (`just skills` prints this list):

- `nix-config-update`: bump the root flake's and the labs' inputs, and review what changed
- `nix-config-debug`: find why an eval, build or CI run of this repo fails
- `nix-best-practices`: review `flake.nix` and the labs' flakes for structure and overlays
- `ultimate-nixos`: audit `configuration.nix` and `home.nix` for current NixOS idioms and hardening
- `systemd-hardening`: sandbox the services `configuration.nix` defines
- `nix-package-patching`: update `supabase-package.nix` and the other local package pins
- `nixpkgs-review`: check a nixpkgs PR before the flake relies on it
- `graphify`: map this repo (or a marola repo) as a graph, then ask it about structure and hubs

The rest (`nix`, `nixos-managing`, `nixos-usb-recovery`) are reference: they load when the task
calls for them, such as installing or rescuing the workstation.

Licence texts are in `LICENSES/`. To refresh one, copy the upstream file at a newer commit,
keep the note, and update the commit here.

No ready-made Nix *subagents* were found: the big agent collections (VoltAgent's
awesome-claude-code-subagents, wshobson/agents, 0xfurai/claude-code-subagents) have none, and the
Nix community ships skills plus MCP servers (mcp-nixos) instead, so this directory is skills only.
