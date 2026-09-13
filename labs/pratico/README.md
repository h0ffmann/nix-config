# prático

The lab that ww-lab consumes: a **reproducible WAVEWATCH III toolchain** (Fortran / C++ /
MPI / NetCDF, one locked nixpkgs), an interactive shell on top of it with a local zsh pilot
(**zsh-ai → llm → Ollama**, Qwen coder), and the **ai-jail** recipes for running Claude Code /
OpenCode sandboxed.

```
just ww3              # toolchain-only shell — what ww-lab builds WW3 in
just ww3-run <cmd>    # one command inside that shell, e.g. just ww3-run cmake -S model -B build ...
just toolchain        # exact versions of everything (nixpkgs rev, gfortran, OpenMPI, NetCDF, ...)
just smoke            # Fortran 2008 + MPI + NetCDF-4 smoke test in the Nix sandbox (what CI runs)

just dev              # interactive shell: same toolchain + zsh-ai + ai-jail, re-execs into zsh
just pull             # ollama pull qwen2.5-coder:7b (once)
just jco / jcf / jcs  # Claude Code (opus / fable / sonnet) inside ai-jail
just jo               # OpenCode inside ai-jail
```

## The WW3 toolchain (`nix develop .#ww3`)

Everything WW3's CMake build (v6.07+) and the classic `w3_make` path look for, from the one
nixpkgs revision pinned in `flake.lock`, so a build on a laptop, in CI, or on a cluster login
node links the same gfortran / OpenMPI / NetCDF bit for bit:

| Piece | Package | Notes |
|---|---|---|
| Compilers | `gfortran` (GCC 15) | `FC`/`F77`/`F90`/`CC`/`CXX` exported |
| MPI | `openmpi` 5 | `mpifort`, `mpicc`, `mpirun`; oversubscription on for single-node runs |
| NetCDF | `netcdf`, `netcdffortran`, `hdf5`, `zlib`, `curl` | `NETCDF`, `NETCDF_FORTRAN`, `NETCDF_CONFIG`, `WWATCH3_NETCDF=NC4` exported; `nc-config`/`nf-config` on PATH |
| Domain decomposition | `metis`, `parmetis` | `METIS_PATH`, `PARMETIS_PATH` exported. ParMETIS is unfree in nixpkgs; the flake allows exactly that one package. nixpkgs' SCOTCH has no PT-SCOTCH, so it is on PATH for `gpart`/`gord` only |
| GRIB | `eccodes` | forcing and post-processing; NCEPLIBS-g2/w3emc are not packaged, so WW3's own GRIB2 output stays off |
| Build | `cmake`, `ninja`, `gnumake`, `pkg-config`, `perl` | |
| Analysis | `nco`, `cdo`, python with numpy / scipy / xarray / netCDF4 / matplotlib | |

`checks.<system>.toolchain` compiles and runs a WW3-shaped program in the sandbox (MPI
singleton, NetCDF-4 write, `ncdump` read-back) and keeps `versions.txt` next to the output.
`nix flake check` builds it; so does CI on every push.

### Using it from ww-lab

```
nix develop ./nix-config/labs/pratico#ww3 --command cmake -S model -B build -DSWITCH=... -DCMAKE_INSTALL_PREFIX=install
nix develop ./nix-config/labs/pratico#ww3 --command cmake --build build -j
just -f nix-config/labs/pratico/justfile toolchain      # record the versions with the results
```

Fetching the flake through a git URL rather than a path needs `?submodules=1`.

## The interactive shell (`nix develop`, `just dev`)

The toolchain plus zsh, fzf, just, `llm` + `llm-ollama`, and ai-jail. Your real `~/.zshrc`
loads the plugin when the shell exports the path:

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

## Layout

Self-contained on purpose: no reference to the parent flake, every recipe anchored on
`justfile_directory()`, so it works unchanged with nix-config as a git submodule.
