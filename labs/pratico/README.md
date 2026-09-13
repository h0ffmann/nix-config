# prático

A local pilot for zsh: **zsh-ai → llm → Ollama** (Qwen coder), packaged as a Nix dev shell,
plus the **ai-jail** recipes for running Claude Code / OpenCode sandboxed.

```
just dev              # nix develop, re-execs into zsh with the plugin wired
just pull             # ollama pull qwen2.5-coder:7b (once)
just ask "…"          # one-shot llm question (inside the shell)
just jco / jcf / jcs  # Claude Code (opus / fable / sonnet) inside ai-jail
just jo               # OpenCode inside ai-jail
just jail-dry-run -- <cmd>
```

Your real `~/.zshrc` loads the plugin when the shell exports the path:

```zsh
[[ -n "$ZSH_AI_PLUGIN" ]] && source "$ZSH_AI_PLUGIN"
```

Inside the shell, press `^o` on a natural-language prompt line and zsh-ai asks the local
model for command suggestions (fzf picks one). `LLM_MODEL` / `ZSH_AI_LLM_NAME` are set to
the same model so `llm` and the plugin agree.

## ai-jail

`.ai-jail` is the committed project policy (it can only tighten). Per-machine trust goes in
`~/.ai-jail`. Recipes forward the host's GitHub token (`scripts/gh-token.sh`) because
`~/.config/gh` is deliberately not mapped into the jail. `PRATICO_JAIL_CLIPBOARD=1` starts a
write-only clipboard relay so `just clip` works from inside.

## As a submodule (ww-lab)

This directory is self-contained: no reference to the parent flake, and every recipe is
anchored on `justfile_directory()`. From ww-lab:

```
nix develop ./nix-config/labs/pratico
just -f nix-config/labs/pratico/justfile jco
```

Fetching the flake through git (rather than a path) needs `?submodules=1` on the URL.
