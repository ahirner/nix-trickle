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

check-pkg-default-overlay() {
  tem=$1; pkg=$2
  (cd $tem
   nix build ."#"$pkg && flake=$(readlink result)
   rm result
   nix-build -A $pkg && defex=$(readlink result)
   echo "flake $flake"
   echo "defex $defex"
   if [ "$flake" != "$defex" ]; then exit 1; fi
  )
}

check-pkg-default() {
  tem=$1; pkg=$2
  (cd $tem
   nix build ."#"$pkg && flake=$(readlink result)
   nix-build -A $pkg && defex=$(readlink result)
   echo "flake $flake"
   echo "defex $defex"
   if [ "$flake" != "$defex" ]; then exit 1; fi
  )
}

check-pkg-overlayed() {
  tem=$1; pkg=$2
  echo "only succeeds on hosts where nixpkgs!=nix-trickle in NIX_PATH and $pkg differs"
  (pushd $tem
   nix build ."#"$pkg && flake=$(readlink result)
   popd
   nix-build '<nixpkgs>' -A $pkg && host=$(readlink result)
   echo "flake $flake"
   echo "host  $host"
   if [ "$flake" == "$host" ]; then exit 1; fi
  )
  tem=$1; pkg=$2
  defex=$(nix-build ./$tem -A $pkg && readlink ./$tem/result)
  host=$(nix-build '<nixpkgs>' -A $pkg && readlink result)
}

set -e
cmd=$1
if [ "$cmd" = "check" ] || [ "$cmd" = "clone" ]; then
  for arg in "${@:2}"; do $cmd $arg; done
else
  for arg in "${@:3}"; do $cmd $2 $arg; done
fi
