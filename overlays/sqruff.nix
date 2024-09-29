final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  sqruff = rustPlatform.buildRustPackage rec {
    pname = "sqruff";
    version = "0.18.2";

    src = fetchFromGitHub {
      owner = "quarylabs";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-LLRBnyRJCXwCTbollsFtl+w5/Urq36xTcYNzpQF/f+k=";
    };
    cargoHash = "sha256-ps6+yCbhU5LwaG6pzEclHn0EXMuA3wtr8XT7xjVvpSQ=";
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
