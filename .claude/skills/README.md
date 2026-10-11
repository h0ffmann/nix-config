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

Licence texts are in `LICENSES/`. To refresh one, copy the upstream file at a newer commit,
keep the note, and update the commit here.
