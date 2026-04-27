final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv rustPlatform runCommand;
  src = fetchFromGitHub {
    owner = "ahirner";
    repo = "spiceai";
    rev = "feature/spice-2.0.0-unstable";
    hash = "sha256-o6rDcZwFuFTsoiYqZ/X+hjDYKhLl8qx9uO+sy9aIJgU=";
  };

  cleanCargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "spiced-2.0.0-unstable-vendor";
    hash = "sha256-0MfGRd4QdUcM+u97nF5qtVEbVcaVVrUWPpSuQd59LQM=";
    postBuild = ''
      rm -f "$out"/git/*/candle-book/Cargo.toml
    '';
  };

  patchedCargoDeps =
    runCommand "spiced-vendor-patched" {
      inherit cleanCargoDeps;
    } ''
      mkdir -p $out
      find $cleanCargoDeps -maxdepth 1 -mindepth 1 -exec ln -s {} $out/ \;
      rm $out/vortex-0.1.0
      cp -r $cleanCargoDeps/vortex-0.1.0 $out/
      chmod -R +w $out/vortex-0.1.0
      sed -i 's/^#!\[doc = include_str!/\/\/ &/' $out/vortex-0.1.0/src/lib.rs
    '';
in {
  spiced = rustPlatform.buildRustPackage {
    inherit src;
    pname = "spiced";
    version = "2.0.0-unstable";

    cargoDeps = patchedCargoDeps;

    buildNoDefaultFeatures = true;
    buildFeatures = ["flightsql" "postgres" "sqlite" "release"];

    env = {OPENSSL_NO_VENDOR = 1;};
    nativeBuildInputs = with prev; [pkg-config cmake protobuf installShellFiles rustPlatform.bindgenHook];
    buildInputs = with prev;
      [openssl.dev]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [apple-sdk];

    # too much hassle
    doCheck = false;

    meta = {
      description = "CDN for databases";
      homepage = "https://docs.spiceai.org";
      license = lib.licenses.asl20;
      maintainers = [];
    };

    passthru.patchedCargoDeps = patchedCargoDeps;
  };
}
