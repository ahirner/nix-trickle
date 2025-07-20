final: prev: let
  system = prev.system;
  pkgs =
    import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
      sha256 = "1yj6j84a92848g2xv8q1pzn6c0b5ivarf01l0nii6r8f1rf1zb24";
    }) {
      inherit (prev) system;
    };
in {
  opencode = pkgs.opencode.overrideAttrs (finalAttrs: prev: let
    opencode-node-modules-hash = {
      "x86_64-darwin" = "sha256-AN1Ha/les1ByJGfVkLDibfxjPouC0tAZ//EN3vDi1Hc=";
      # todo: other hashes
      "aarch64-darwin" = "";
      "aarch64-linux" = "";
      "x86_64-linux" = "";
    };
    version = "0.3.43";
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-EM44FkMPPkRChuLcNEEK3n4dLc5uqnX7dHROsZXyr58=";
    };
  in {
    inherit version src;
    tui = prev.tui.overrideAttrs (prev: {
      inherit (finalAttrs) version;
      src = "${finalAttrs.src}/packages/tui";
      vendorHash = "sha256-/YxvM+HZM4aRqcjUiSX0D1DhhMJkmLdh7G4+fPqtnic=";
    });
    node_modules = prev.node_modules.overrideAttrs (prev: {
      inherit (finalAttrs) version src;
      outputHash = opencode-node-modules-hash.${system};
    });
  });
}
