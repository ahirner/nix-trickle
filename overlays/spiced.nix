final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv;
  rustPlatform = prev.makeRustPlatform {
    cargo = prev.rust-bin.stable.latest.default;
    rustc = prev.rust-bin.stable.latest.default;
  };
in {
  spiced = rustPlatform.buildRustPackage rec {
    pname = "spiced";
    version = "1.0.0-rc.2";

    src = fetchFromGitHub {
      owner = "ahirner";
      repo = "spiceai";
      rev = "609fdc1451a18ebac799f1418d7c9fb094fc5dca";
      hash = "sha256-KndNMDj2FlUwCAmSywRe8vrvLD5ymEgI9gtBPKDIPyM=";
    };
    # hangs during fetch.. at least on my machine (tm)
    #cargoDeps = rustPlatform.fetchCargoVendor {
    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "arrow-json-53.1.0" = "sha256-izPR29oC3dy6Sn83wbcI1CBLXtQNuNjhh65I75YnhDM=";
        "arrow-odbc-11.2.0" = "sha256-u3Q+SG+3zxwbaR5nIDtQZsemNZ3kAuA+Pgvo9WkvORw=";
        "async-openai-0.26.0" = "sha256-0PjmSjPD3vg6QC3eQJ04zvdm2I4Jn3N+NOtkr7Xbzk0=";
        "bindgen_cuda-0.1.6" = "sha256-OWGcQxT+x5HyIFskNVWpPr6Qfkh6Mv/g4PVSm5oA27g=";
        "candle-core-0.8.0" = "sha256-S0X8Ui+/lHTuJ+a6EBPZ9TS4e73e0vGnsingouxGX8M=";
        "candle-cublaslt-0.2.2" = "sha256-EWkzujNNz5KG/Q6O7t9C9Nsdb80S/uzajqeDuE9TviY=";
        "candle-layer-norm-0.0.1" = "sha256-EpBvNh1CcqyiNB0Q+zB4eVsW+EVoTBBKWvyrut2ss2s=";
        "candle-rotary-0.0.1" = "sha256-UlZ1RP9EM7BaVWfMsvJwMlHEw4+TNXuLTMaUdXtF9TU=";
        "clickhouse-rs-1.1.0-alpha.1" = "sha256-Dmd+m7I/WMy+gFdFX4/osgIBu6fRGEQDIhjKUF7wLL4=";
        "cudarc-0.10.0" = "sha256-iVmYbiAgZhgsHTHkPF46MPqbPpwvS+HhPD9FmB+Vc5c=";
        "datafusion-43.0.0" = "sha256-39po97oU/FonpDnyRsHWd66nba6GbSTVMK4kNqTgbCg=";
        "datafusion-federation-0.1.6" = "sha256-st+BIoVCNl3AlIwYd8xzH7F6+21SHpewTOiWBNxheeQ=";
        "datafusion-table-providers-0.1.0" = "sha256-/zP9jqBBs4xDTQ8XQh40Xt0soYGwmsrMfshEYGnWPn8=";
        "delta_kernel-0.6.0" = "sha256-nfz8Gk9UWYc/ezdkGo1hgUHKlV+/nBwRUNbsWjKPHmg=";
        "derivre-0.1.0" = "sha256-dQDIdlO5iIHXHXGHpz8/4QGeB6VuGuZ7TZE+OJvOWBo=";
        "docx-rs-0.4.17" = "sha256-6rYJ5LJ9K7H+nPDelJ+Wq6w+Oy18sArcVDoINBG4bjM=";
        "dotenvy-0.15.7" = "sha256-0TQPTq5FQPenk4kHw0FXppZDelC6pAGF0+k9/W6K7AY=";
        "graph-core-2.0.1" = "sha256-IG2LLYkkZgWS7DGkpLVs2ZkTgBiDx/Oi9QeaRSsafb0=";
        "libsqlite3-sys-0.28.0" = "sha256-zFH/5FeW0qnAC/t0rs4bCeIspYE+F1Dn0gwHn/mre7U=";
        "llguidance-0.6.0" = "sha256-+78jvIIUqKmBDpAVnuPFguumb8V+aPSXuMcCI0hZ5gs=";
        "toktrie_hf_tokenizers-0.1.0" = "sha256-S4rPLL7wJgAAZ/6AeVzCSZLvqQKYt9XexneKw7Ph6u8=";
        "lopdf-0.34.0" = "sha256-gf+9uVqZOhZGjC0hWRFFA2/vAuXLtiffErPoK+zEMG0=";
        "mistralrs-0.3.4" = "sha256-V4XlrlLsbMqDySPww4e1SoTHI1IDpgQrjoKyOaY0Usc=";
        "object_store-0.11.1" = "sha256-lmV5o4HC0lFH5l3fYATrEtn+miym9gP5I6FMh+kTfe0=";
        "odbc-api-8.1.2" = "sha256-2MWPO/BvsxTmwyM1//jt1JZJb2qjDNP44Dt7JAo1vjg=";
        "sea-query-0.32.0-rc.1" = "sha256-mxSoUzN7obNHhooNrnq68IQUVbq1hTrX2CrOwE7xXok=";
        "snowflake-api-0.9.0" = "sha256-bAQLteocuZ8ha5od3suLTfHXJk2JMj2A2K1Us5Wunbw=";
        "spark-connect-core-0.0.1-beta.4" = "sha256-wW6dyh8br7NJhlDZEYhv6kojBdYwhBCskrH9SMfGbWE=";
        "text-embeddings-backend-1.5.0" = "sha256-XHXxxaQmwvGudUsVDAquM4zE+vU346MBxRxtqaCxusA=";
        "text-splitter-0.18.1" = "sha256-tyVldl0zDjd0h6vW37tVkfstMMCj/t+aDR+tp/kUNCM=";
        # :) "duckdb-1.1.3" = "sha256-3jcjR9ydxTQCW6KRJ6FFGABoBXYmqB39gOXt96SRwdI=";
        "opentelemetry-prometheus-0.17.0" = "sha256-KjPqfxnXoxVKZ63nL8v7yKr7KN6z0ZoChuTZpjVV0cI=";
      };
    };

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
