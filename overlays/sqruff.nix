final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  sqruff = rustPlatform.buildRustPackage rec {
    pname = "sqruff";
    version = "0.28.2";

    src = fetchFromGitHub {
      owner = "quarylabs";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-a4B8X4Jv18m3NutdEgO9pIWxVfe9prTjwsyFolZrkCk=";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-j9yI1e/+kfuseXydSuIWmh9REYTKZfC2rd/n+OagUBs=";

    buildNoDefaultFeatures = true;
    nativeBuildInputs = [
      # disabling features doesn't help to un-require pyo3 as in prev 0.25.28
      # because some build.rs invokes pyo3-build-config :)
      prev.python3
    ];

    # tests/ui.rs refers to ../../target/release/sqruff which doesn't exist in nix
    doCheck = false;

    meta = {
      description = "Fast SQL formatter/linter";
      homepage = "https://github.com/quarylabs/sqruff";
      changelog = "https://github.com/quarylabs/sqruff/releases/tag/${version}";
      license = lib.licenses.asl20;
      mainProgram = "sqruff";
      maintainers = with lib.maintainers; [hasnep];
    };
  };
}
