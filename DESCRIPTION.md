# nix-config, for the LinkedIn Projects section

Self-contained Nix flakes ("labs") for the toolchains I work in: WAVEWATCH III (gfortran, OpenMPI, NetCDF), a pandoc + TeX Live publishing pipeline with its GitHub Action, and a lint set. Any repo can borrow one as a flake input, submodule or action; CI builds each on every push. Inspired by gvolpe/nix-config.
