final: prev: let
  system = prev.system;
  pkgs =
    import (fetchTarball {
      url = "https://github.com/nixos/nixpkgs/tarball/c87b95e25065c028d31a94f06a62927d18763fdf";
      sha256 = "0dr3sicmyizjflsykzgmymlxflqd0bs743i11bkymi157ln82bim";
    }) {
      inherit (prev) system;
    };
in {
  opencode = pkgs.opencode.overrideAttrs (finalAttrs: prev: let
    opencode-node-modules-hash = {
      "x86_64-darwin" = "sha256-AN1Ha/les1ByJGfVkLDibfxjPouC0tAZ//EN3vDi1Hc=";
      "x86_64-linux" = "sha256-XIRV1QrgRHnpJyrgK9ITxH61dve7nWfVoCPs3Tc8nuU=";
      # todo: other hashes
      "aarch64-darwin" = "";
      "aarch64-linux" = "";
    };
    version = "0.3.55";
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-eOsazBjkdTvGNsobb5WUBDB2udEJh9zkOeMfVH/tkQo=";
    };
  in {
    inherit version src;
    tui = prev.tui.overrideAttrs (prev: {
      inherit (finalAttrs) version;
      src = "${finalAttrs.src}/packages/tui";
      vendorHash = "sha256-6sSUvmxVqrqPqPW0JdLnDP1sMYhwqD814qoj2ey/z5E=";
    });
    node_modules = prev.node_modules.overrideAttrs (prev: {
      inherit (finalAttrs) version src;
      outputHash = opencode-node-modules-hash.${system};
    });
  });
}
