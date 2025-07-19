final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  spiced = rustPlatform.buildRustPackage {
    pname = "spiced";
    version = "1.5-rc";

    src = fetchFromGitHub {
      owner = "ahirner";
      repo = "spiceai";
      rev = "chore/spiceai_1.5";
      hash = "sha256-FjhTs7y6wwVblDsm0/NRDlr+Qao7SB+D6+CwJVFbpzo=";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-HEHiDRQK6+m2dhPMWI4WzEmB+OhEyv2YQv/mHgQ1tOk=";

    buildNoDefaultFeatures = true;
    buildFeatures = ["flightsql" "postgres" "sqlite" "release"];

    env = {OPENSSL_NO_VENDOR = 1;};
    nativeBuildInputs = with prev; [pkg-config cmake installShellFiles rustPlatform.bindgenHook];
    buildInputs = with prev;
      lib.optionals (! stdenv.hostPlatform.isDarwin) [openssl]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        darwin.apple_sdk.frameworks.Security
        apple-sdk_15
        # aws-lc-sys requires CryptoKit's CommonCrypto, which is available on macOS 10.15+
        # c.f: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/co/conduwuit/package.nix
        (darwinMinVersionHook "10.15")
      ];

    # too much hassle
    doCheck = false;

    meta = {
      description = "CDN for databases";
      homepage = "https://docs.spiceai.org";
      license = lib.licenses.asl20;
      maintainers = [];
    };
  };
}
