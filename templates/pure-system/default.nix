{}: let
  flake = builtins.getFlake (builtins.toString ./.);
in
  # flake-utils-plus' mkFlake exports pkgs as pkgs.{system}.{channel.name}
  flake.pkgs.${builtins.currentSystem}.nixpkgs
