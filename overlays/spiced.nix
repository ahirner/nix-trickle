final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  spiced = rustPlatform.buildRustPackage {
    pname = "spiced";
    version = "1.1.0-rc";

    src = fetchFromGitHub {
      owner = "ahirner";
      repo = "spiceai";
      rev = "chore/merge_trunk";
      hash = "sha256-B+CMyLGSmDmKoA9xJRQO2E8BXJbZFrVOZQvPX30NVEM=";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-mjdJUdI4Tl3ZAQMyVI2EDUnFizMNJHObpfxTCJQOVJU=";

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
