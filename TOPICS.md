# GitHub topics

The topics set on this repository, at GitHub's limit of 20. Each one names something the repo
actually ships, so a search for it lands on a lab that answers it.

| Topic | Why |
|---|---|
| `nix` | every lab is a Nix flake |
| `nix-flakes` | the labs are consumed as flake inputs (`?dir=labs/<lab>`) |
| `nixos` | the root is the workstation's NixOS system |
| `nixpkgs` | labs pin nixos-unstable, the root nixos-26.05 |
| `home-manager` | the root system's user config |
| `nix-config` | the name people search for this kind of repo (as gvolpe/nix-config) |
| `devshell` | each lab exports `devShells.<system>.default` |
| `reproducible-builds` | committed locks, CI builds every lab with `--no-update-lock-file` |
| `development-environment` | what a lab is, for people who don't search Nix terms |
| `github-actions` | labs/publisher ships a composite Action |
| `wavewatch3` | labs/pratico: the WAVEWATCH III toolchain |
| `fortran` | labs/pratico: gfortran |
| `mpi` | labs/pratico: OpenMPI |
| `netcdf` | labs/pratico: NetCDF |
| `pandoc` | labs/publisher |
| `latex` | labs/publisher: TeX Live, lualatex |
| `cuda` | labs/cuda and the NVIDIA system config |
| `pytorch` | labs/cuda: the torch venv |
| `ai-agents` | labs/agentic: ai-jail, OpenCode, Open Code Review |
| `sandbox` | labs/agentic: `jail-run` sandboxes coding agents |

Apply them (adds to the topics already set; drop old ones with `--remove-topic`):

```console
gh repo edit h0ffmann/nix-config \
  --add-topic nix,nix-flakes,nixos,nixpkgs,home-manager,nix-config,devshell,reproducible-builds \
  --add-topic development-environment,github-actions,wavewatch3,fortran,mpi,netcdf,pandoc,latex \
  --add-topic cuda,pytorch,ai-agents,sandbox
```

When a lab is added or dropped, swap its topics here and re-run the command.
