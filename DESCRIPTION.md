# picasso (formerly nix-config), for the LinkedIn Projects section

Self-contained Nix flakes ("labs") for the toolchains I work in: WAVEWATCH III (gfortran, OpenMPI, NetCDF), a pandoc + TeX Live publishing pipeline with its own GitHub Action, a toolchain for Markdown papers (pandoc-crossref, XeLaTeX, arXiv), a Gleam toolchain for static sites, a lint set, a sandbox for coding agents, CUDA and PyTorch host setup, a presenter's desk (annotate, capture, webcam profiles), and a code graph of any repository (graphify). Any repo can borrow a lab as a flake input, a submodule or an Action, and CI builds each one on every push. The same flake defines my NixOS workstation and a one-command VM (`just vm`). It is the toolchain layer under WW3 GPU Lab and marola. Inspired by gvolpe/nix-config.

## One line (the GitHub "About" box)

Self-contained Nix flakes for WAVEWATCH III, publishing, CUDA and coding agents, plus the NixOS workstation they run on.

Apply it:

```console
gh repo edit h0ffmann/picasso \
  --description "Self-contained Nix flakes for WAVEWATCH III, publishing, CUDA and coding agents, plus the NixOS workstation they run on." \
  --homepage "https://github.com/h0ffmann/picasso"
```

The citation title and abstract live in `.zenodo.json` (`CITATION.cff` is generated from it);
change them together with this page when what the repo is changes.
