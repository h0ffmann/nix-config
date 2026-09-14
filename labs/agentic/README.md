# agentic

The sandbox for coding agents, and the host-side scripts around it: **ai-jail**
(bubblewrap / Landlock / seccomp, Linux), **OpenCode**, **gh**, and four scripts that are one
file each, run from source by CI and wrapped by `writeShellApplication` for consumers:

| Script | Does |
|---|---|
| `jail-run claude [args]` / `jail-run opencode [args]` | the agent inside ai-jail, from the current directory, with the host's GitHub token forwarded as `GH_TOKEN`; `jail-run --dry-run -- <cmd>` prints the sandbox line and runs nothing |
| `gh-token` / `gh-token --source` | the token a jail should get: `GH_TOKEN`, then `GITHUB_TOKEN`, then the host's `gh auth token`. `~/.config/gh` is never mapped into a jail, so a login inside it dies with the sandbox — authenticate once, on the host |
| `clip` | write-only clipboard push from inside the jail (or outside); no paste counterpart, by design |
| `clip-relay <fifo>` | the host half of that bridge; `jail-run` starts it when `JAIL_CLIPBOARD=1` |

```
just shell            # the tools on PATH
just self-test        # every script's --self-test, from source
just jco / jcf / jcs  # Claude Code (opus / fable / sonnet) inside ai-jail — in YOUR directory ([no-cd])
just jo               # OpenCode inside ai-jail
just jail-dry-run ls  # what ai-jail would run for `ls`
```

Two opt-ins, both off by default: `JAIL_CLIPBOARD=1` starts a write-only clipboard relay the
jail reaches through `<project>/.tmp/clip.fifo` (the project directory is what ai-jail maps in,
so the fifo has to live there); `JAIL_CLIPBOARD_PASTE=1` passes the real X11/Wayland display
through, which lets Claude Code's own image paste work but also lets the jail *read* the
clipboard (and, on X11, other windows). `--exec` — direct execution, no PTY proxy — is what keeps
Ctrl+C and bracketed paste working; the proxy owned the raw terminal and relayed neither.

## The project's `.ai-jail`

Committed per project, an untrusted layer that can only tighten; per-machine trust goes in
`~/.ai-jail`. The policy every consumer of this lab uses today:

```toml
command = ["claude"]
rw_maps = ["~/.claude", "~/.claude.json"]
mask = [".env", ".env.*", "*.pem", "*.key"]
network = true
terminal_passthrough = true
```

## Reusing it from another repository

```nix
{
  inputs.agentic = { url = "github:h0ffmann/nix-config?dir=labs/agentic"; inputs.nixpkgs.follows = "nixpkgs"; };
  outputs = { nixpkgs, agentic, ... }:
    let system = "x86_64-linux"; in {
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell ({
        packages = [ /* the project's own tools */ ] ++ agentic.lib.${system}.tools;
      } // agentic.lib.${system}.env);   # BWRAP_BIN on Linux
    };
}
```

and the consumer's recipes are one line each:

```just
jail-claude *args:
    jail-run claude {{args}}
jail-dry-run *cmd:
    jail-run --dry-run -- {{cmd}}
```

`lib.${system}` exposes `tools` (the list), `env` (`BWRAP_BIN`, Linux) and `scripts` (the four
packages); `packages.${system}.<script>` for `nix run`; `checks.${system}.{gh-token,jail-run}`
run the self-tests in the sandbox against fakes on `PATH`.

First consumer: [marola](https://github.com/h0ffmann/marola). `labs/pratico` still carries its
own copies of these scripts and recipes; making it consume this lab is a follow-up.
