final: prev: let
  inherit (prev) lib fetchFromGitHub;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  spiced = rustPlatform.buildRustPackage rec {
    pname = "spiced";
    version = "0.20.0-beta";

    buildNoDefaultFeatures = true;
    buildFeatures = ["flightsql" "postgres" "sqlite" "release"];

    src = fetchFromGitHub {
      owner = "spiceai";
      repo = "spiceai";
      rev = "v${version}";
      hash = "sha256-MAS5EB1qCsRa3Z29wRDI/RdRsATn7hh/rpk8j+t5Zi0=";
    };
    cargoLock = {
      lockFile = ./spiceai/Cargo.lock;
      allowBuiltinFetchGit = true;
      #outputHashes = {
      #  "arrow-json-53.1.0" = "";
      #};
    };
    postPatch = ''
      cp ${./spiceai/Cargo.lock} Cargo.lock
    '';
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
