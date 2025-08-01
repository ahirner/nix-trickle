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
      "x86_64-darwin" = "sha256-lZRV/CqGXgvAtzFZS4w9ry5yqHT4EYuQ4exuDdXCxBY=";
      "x86_64-linux" = "sha256-qW/5VKxGuIARVOMPflET74mvIMootj4QHBt2X9sH094=";
      # todo: other hashes
      "aarch64-darwin" = "";
      "aarch64-linux" = "";
    };
    version = "0.3.110";
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-2fvUSbQWBxjXLRfVFwJ6VNO2tx+qGa+IDRCSwFPqw+o=";
    };
  in {
    inherit version src;
    tui = prev.tui.overrideAttrs (prev: {
      # root src to fix reachging out to ../sdk/go introduced in https://github.com/sst/opencode/commit/a5b20f9
      inherit (finalAttrs) version src;
      sourceRoot = "source/packages/tui";

      vendorHash = "sha256-nBwYVaBau1iTnPY3d5F/5/ENyjMCikpQYNI5whEJwBk=";
    });
    node_modules = prev.node_modules.overrideAttrs (prev: {
      inherit (finalAttrs) version src;
      outputHash = opencode-node-modules-hash.${system};
    });
  });
}
