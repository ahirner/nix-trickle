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
      "x86_64-darwin" = "sha256-4NaHXeWf57dGVV+KP3mBSIUkbIApT19BuADT0E4X+rg=";
      "x86_64-linux" = "sha256-7Hc3FJcg2dA8AvGQlS082fO1ehGBMPXWPF8N+sAHh2I=";
      # todo: other hashes
      "aarch64-darwin" = "";
      "aarch64-linux" = "";
    };
    version = "0.4.1";
    src = pkgs.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-LEFmfsqhCuGcRK7CEPZb6EZfjOHAyYpUHptXu04fjpQ=";
    };
  in {
    inherit version src;
    tui = prev.tui.overrideAttrs (prev: {
      # root src to fix reachging out to ../sdk/go introduced in https://github.com/sst/opencode/commit/a5b20f9
      inherit (finalAttrs) version src;
      sourceRoot = "source/packages/tui";

      vendorHash = "sha256-jGaTgKyAvBMt8Js5JrPFUayhVt3QhgyclFoNatoHac4=";
    });
    node_modules = prev.node_modules.overrideAttrs (prev: {
      inherit (finalAttrs) version src;
      outputHash = opencode-node-modules-hash.${system};
    });
  });
}
