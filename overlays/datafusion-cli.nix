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
      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = "${src}/datafusion-cli/Cargo.lock";
      };
      buildInputs =
        old.buildInputs
        ++ prev.lib.optionals prev.stdenv.isDarwin [
          prev.darwin.apple_sdk.frameworks.SystemConfiguration
        ];
      checkFlags =
        old.checkFlags # didn't check to prune old
        ++ [
          "--skip=catalog::tests::query_gs_location_test"
          "--skip=catalog::tests::query_http_location_test"
          "--skip=catalog::tests::query_s3_location_test"
          "--skip=exec::tests::copy_to_external_object_store_test"
          "--skip=exec::tests::copy_to_object_store_table_s3"
          "--skip=exec::tests::create_object_store_table_cos"
          "--skip=exec::tests::create_object_store_table_http"
          "--skip=exec::tests::create_object_store_table_oss"
          "--skip=exec::tests::create_object_store_table_s3"
          "--skip=tests::test_parquet_metadata_works_with_strings"
        ];
    }
  );
}
