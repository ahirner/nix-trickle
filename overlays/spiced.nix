final: prev: let
  inherit (prev) lib fetchFromGitHub stdenv;
  inherit (prev.rustPackages_1_98) rustPlatform cargo rustc;
  isAarch64Linux = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  pdfium = prev.callPackage ./spiced/pdfium.nix {};
  nativeBuildInputs = with prev;
    [pkg-config cmake protobuf installShellFiles rustPlatform.bindgenHook]
    ++ lib.optionals isAarch64Linux [clang lld];
  buildInputs = with prev;
    [openssl.dev]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [apple-sdk];
  # ld64 inserts ARM64 branch islands in __text, not ctor's __text_startup.
  linkerSetup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export NIX_LDFLAGS="''${NIX_LDFLAGS-} -rename_section __TEXT __text_startup __TEXT __text"
  '';
  env = {
    OPENSSL_NO_VENDOR = 1;
    PDFIUM_LIB_PATH = "${pdfium}/lib";
    PDFIUM_INCLUDE_PATH = "${pdfium}/include";
  };
in {
  spiced = rustPlatform.buildRustPackage rec {
    pname = "spiced";
    version = "2.4.2";

    src = fetchFromGitHub {
      owner = "spiceai";
      repo = "spiceai";
      tag = "v${version}";
      hash = "sha256-hCL7atdTU1M45A2kiaimpSOV8FTL/9iQDTdiSe29r00=";
    };
    cargoDeps =
      (rustPlatform.fetchCargoVendor {
        inherit pname version src;
        hash = "sha256-t/hw3yJ6ZOS93Y0C7FpbuW5w+SeU2bVkLguxQJIegXM=";
      }).overrideAttrs (old: {
        # Git vendoring omits Vortex's workspace README.
        buildCommand =
          old.buildCommand
          + ''
            for vortex_library in "$out"/source-git-*/vortex-[0-9]*/src/lib.rs; do
              chmod u+w "$vortex_library" "$(dirname "$vortex_library")"
              sed -i '/^#!\[doc = include_str!/d' "$vortex_library"
            done
          '';
      });

    inherit nativeBuildInputs buildInputs env;
    preBuild = linkerSetup;
    cargoBuildFlags = ["--package=spiced"];
    buildNoDefaultFeatures = true;
    buildFeatures = ["flightsql" "postgres" "sqlite" "vortex" "release"];

    doCheck = false;
    nativeInstallCheckInputs = [prev.versionCheckHook];
    doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
    versionCheckProgramArg = "--version";

    passthru.patchedCargoDeps = cargoDeps;
    passthru.pdfium = pdfium;
    passthru.devShell = prev.mkShell {
      packages = [cargo rustc] ++ nativeBuildInputs;
      inherit buildInputs env;
      shellHook = linkerSetup;
    };

    meta = {
      description = "CDN for databases";
      homepage = "https://docs.spiceai.org";
      license = lib.licenses.asl20;
      mainProgram = "spiced";
      maintainers = [];
    };
  };
}
