final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  sqruff = rustPlatform.buildRustPackage rec {
    pname = "sqruff";
    version = "0.20.0";

    src = fetchFromGitHub {
      owner = "quarylabs";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-lgNRvd7rczuR4sk50sspJsMEDq1TgbIUYNiMs1MIiJk=";
    };
    cargoHash = "sha256-i8RehIMOscf5gbkIrRhI3J05h2U2GOQeLhYsNUkoxBk=";
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
