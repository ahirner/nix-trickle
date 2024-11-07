final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  spiced = rustPlatform.buildRustPackage rec {
    pname = "spiced";
    version = "0.20.0-beta";

    src = fetchFromGitHub {
      owner = "spiceai";
      repo = "spiceai";
      rev = "v${version}";
      hash = "sha256-MAS5EB1qCsRa3Z29wRDI/RdRsATn7hh/rpk8j+t5Zi0=";
    };
    cargoLock = {
      lockFile = ./spiceai/Cargo.lock;
      allowBuiltinFetchGit = true;
    };
    postPatch = ''
      cp ${./spiceai/Cargo.lock} Cargo.lock
    '';

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
