final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  sqruff = rustPlatform.buildRustPackage rec {
    pname = "sqruff";
    version = "0.25.10";

    src = fetchFromGitHub {
      owner = "quarylabs";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-tCx+AeTLssXYXKBa7xwuddM8TPiIU6qaxrXeMTqrE0g=";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-I7DiJqVKHtSxBE2C9/oKOmogG56a7tAdg02YjQ0MbTI=";

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
