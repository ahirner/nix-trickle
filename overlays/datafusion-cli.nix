final: prev: {
  datafusion-cli = prev.datafusion-cli.overrideAttrs (
    old: rec {
      version = "37.0.0";
      src = prev.fetchFromGitHub {
        name = "datafusion-cli-source";
        owner = "apache";
        repo = "arrow-datafusion";
        rev = version;
        hash = "sha256-Gl/fcT+5JsS+5DokVaxPdja8mdCjClHq5QnL5b8MfJk=";
      };
      #sourceRoot = "${src.name}/datafusion-cli";
      #cargoHash = "";
      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = "${src}/datafusion-cli/Cargo.lock";
      };
    }
  );
}
