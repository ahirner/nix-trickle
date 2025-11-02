final: prev: let
  pkgs = prev;
  inherit (prev) fetchFromGitHub rustPlatform;
  version = "0.3.1";
in {
  turso_cli =
    # intentionally w/o custom toolchain for only the main package
    rustPlatform.buildRustPackage {
      pname = "turso-cli";
      inherit version;
      src = fetchFromGitHub {
        owner = "tursodatabase";
        repo = "turso";
        tag = "v${version}";
        hash = "sha256-Cc3bWqgzcEcGFao2k0aGkOpzmYSoJCZlF5Ce50f6xdk=";
      };
      cargoHash = "sha256-AzgcdpNfe4CO56zoD2bS3r9Fsml9BiValJLrURiPTYk=";
      cargoBuildFlags = ["--package" "turso_cli"];
      nativeBuildInputs = [pkgs.python3];
      # dependency from test "compat" in turso_sqlite3
      buildInputs = [pkgs.sqlite];
    };
}
