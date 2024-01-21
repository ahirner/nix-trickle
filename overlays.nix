{lib, ...}: let
  fileNames = dir: (builtins.attrNames (lib.filterAttrs (name: type: type == "regular") (builtins.readDir dir)));
  namedOverlays = builtins.listToAttrs (builtins.map (name: {
      name = lib.removeSuffix ".nix" name;
      value = import (./overlays + "/${name}");
    })
    (fileNames ./overlays));
in
  namedOverlays
