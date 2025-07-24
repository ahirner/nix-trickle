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
      "x86_64-darwin" = "sha256-jwmH4gEcyRNgeMvYz2SyWRagFkYN1O3ULEQIPPgqhwg=";
      "x86_64-linux" = "sha256-ZMz7vfndYrpjUvhX8L9qv/lXcWKqXZwvfahGAE5EKYo=";
      # todo: other hashes
      "aarch64-darwin" = "";
      "aarch64-linux" = "";
    };
    version = "0.3.61";
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-0N4VsGa3l8IWy8YMCuDQJoxWxTQtXQBt0scyPPiRwvI=";
    };
  in {
    inherit version src;
    tui = prev.tui.overrideAttrs (prev: {
      inherit (finalAttrs) version;
      src = "${finalAttrs.src}/packages/tui";
      vendorHash = "sha256-gvWD8ILnA5NxGpiNMcNFUI6YVLMeRGz45pDk0G5zBjc=";
    });
    node_modules = prev.node_modules.overrideAttrs (prev: {
      inherit (finalAttrs) version src;
      outputHash = opencode-node-modules-hash.${system};
    });
  });
}
