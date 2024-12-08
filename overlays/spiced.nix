final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  spiced = rustPlatform.buildRustPackage {
    pname = "spiced";
    version = "1.0.0-rc.2";

    src = fetchFromGitHub {
      owner = "spiceai";
      repo = "spiceai";
      # ahead of $v{version}:
      rev = "b471e895799971423c108aec0a936b9ed6a3d749";
      hash = "sha256-w0VKolgTO3huta/3CrlixzgUzkSsDvo0xqCT/QVX2QY=";
    };
    patches = [../patches/spiceai-Cargo.toml.patch];
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
