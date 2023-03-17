# some improvised check on template configs
# todo: use pkgs.nixosTest?

clone() {
  t=$1
  rm $t/* || true
  mkdir -p $t

  (cd $t
  nix flake init -t ../..#$t
  git init
  git add *)
}

check() {
  (cd $1
  nix flake update --override-input nix-trickle ../..
  nix flake check -L --keep-going
  nix flake show)
}

set -e

$@

