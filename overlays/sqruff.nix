final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatformNightly = prev.makeRustPlatform {
    cargo = prev.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
    rustc = prev.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  };
in {
  sqruff = rustPlatformNightly.buildRustPackage rec {
    pname = "sqruff";
    version = "0.14.0";

    src = fetchFromGitHub {
      owner = "quarylabs";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-S/UmGAThlhKFh58MOD7v5+nPOot+Jh5X2oFdrXYQfkE=";
    };
    cargoHash = "sha256-aofsUUOOmK40dCdDtsHh0ARVCJRr754b5P6sogXjPZA=";
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
