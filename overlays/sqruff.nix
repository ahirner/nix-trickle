final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  sqruff = rustPlatform.buildRustPackage rec {
    pname = "sqruff";
    version = "0.25.28";

    src = fetchFromGitHub {
      owner = "quarylabs";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-Xea6jXQos5gyF1FeGF7B5YaQszqfsKhGw1k8j0m7J6c=";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-agB//UDTsEje9pgig07dUy8/Fr+zx7/MC3AdLjqoKJY=";

    # tests/ui.rs refers to ../../target/release/sqruff which doesn't exist in nix
    doCheck = false;

    meta = {
      description = "Fast SQL formatter/linter";
      homepage = "https://www.quary.dev";
      license = lib.licenses.asl20;
      maintainers = [];
    };
  };
}
