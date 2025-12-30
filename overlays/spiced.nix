final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv rustPlatform;
in {
  spiced = rustPlatform.buildRustPackage {
    pname = "spiced";
    version = "1.5-rc";

    src = fetchFromGitHub {
      owner = "ahirner";
      repo = "spiceai";
      rev = "chore/trunk_fixes";
      hash = "sha256-ZdQzpRX+QUEUNw+93JT1gck9k7aHCbVNRoA0PvfB6qg=";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-OWKGprPjrBwHLB/k85GUvz21+S/8Tr2iEVw56EXAHok=";

    buildNoDefaultFeatures = true;
    buildFeatures = ["flightsql" "postgres" "sqlite" "release"];

    env = {OPENSSL_NO_VENDOR = 1;};
    nativeBuildInputs = with prev; [pkg-config cmake installShellFiles rustPlatform.bindgenHook];
    buildInputs = with prev;
      lib.optionals (! stdenv.hostPlatform.isDarwin) [openssl]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        apple-sdk
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
