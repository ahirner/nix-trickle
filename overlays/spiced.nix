final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv rustPlatform;
in {
  spiced = rustPlatform.buildRustPackage {
    pname = "spiced";
    version = "1.10-rc";

    src = fetchFromGitHub {
      owner = "ahirner";
      repo = "spiceai";
      rev = "feature/spice_1.10.3-rc";
      hash = "sha256-oSSugt9pa0rs8e4wecDHiaCVTGqznP45KwGHZ0SDT4E=";
    };
    cargoHash = "sha256-PvDuW1KBvvsC1wf3NfxEOXP3qEQGANZvNRK0gbazpYA=";

    buildNoDefaultFeatures = true;
    buildFeatures = ["flightsql" "postgres" "sqlite" "release"];

    env = {OPENSSL_NO_VENDOR = 1;};
    nativeBuildInputs = with prev; [pkg-config cmake protobuf installShellFiles rustPlatform.bindgenHook];
    buildInputs = with prev;
      lib.optionals (! stdenv.hostPlatform.isDarwin) [openssl.dev]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        apple-sdk
        # aws-lc-sys requires CryptoKit's CommonCrypto, which is available on macOS 10.15+
        # c.f: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/co/conduwuit/package.nix
        #(darwinMinVersionHook "10.15")
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
