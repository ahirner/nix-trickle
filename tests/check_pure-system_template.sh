# some improvised check on template configs
# todo: use pkgs.nixosTest?

rm pure-system/*
rmdir pure-system

set -ex
mkdir pure-system && cd pure-system

nix flake init -t ../..#pure-system
git add .
nix flake update --override-input nix-trickle ../..
nix flake check -L --keep-going
nix flake show
