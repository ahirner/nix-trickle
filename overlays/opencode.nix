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
      "x86_64-darwin" = "sha256-xu7iiXbg3Wr7A+joilIC2+tk29BXUJydTjohTenyHNU=";
      "x86_64-linux" = "sha256-mapp+765B/Tgfg38GmPaKDXMwE1Zx/mxlXwxZ4+zfvk=";
      # todo: other hashes
      "aarch64-darwin" = "";
      "aarch64-linux" = "";
    };
    version = "0.3.71";
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-iVIWG53Gd2aATXzijAAIW5qT7YfYZwm62Y6I4dDVWGU=";
    };
  in {
    inherit version src;
    tui = prev.tui.overrideAttrs (prev: {
      inherit (finalAttrs) version;
      src = "${finalAttrs.src}/packages/tui";
      vendorHash = "sha256-0nKjp9CuqnhWfsqgwsfdCdx7pR2kzr+WEP5c990ow3Y=";
    });
    node_modules = prev.node_modules.overrideAttrs (prev: {
      inherit (finalAttrs) version src;
      outputHash = opencode-node-modules-hash.${system};
    });
  });
}
