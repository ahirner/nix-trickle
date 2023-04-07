final: prev: let
  /*
   Replace regex matches with another string.

  Type: regPlace :: (string -> string -> string -> string)

  */
  regPlace = reg: sub: str:
    builtins.foldl' (x: y: x + y) "" (builtins.map (x:
      if builtins.isString x
      then x
      else sub) (builtins.split reg str));
in {
  # gsutil doesn't work with openssl but pyopenssl
  google-cloud-sdk = prev.google-cloud-sdk.overrideAttrs (old: let
    # one cannot understand why python in old default.nix was magically python3...
    pythonEnv = prev.python3.withPackages (p:
      with p; [
        cffi
        cryptography
        # openssl is gone, instead:
        pyopenssl
        crcmod
        numpy
      ]);
    # give gcloud stuff the fixed python withPackages,
    # also remove alpha/beta modules (not needed and error with missing /nix/store)
    installPhase' =
      regPlace "cp /nix/store.*\__init__.py\n" ""
      (regPlace "PYTHONPATH : [^\\]+" "PYTHONPATH : ${pythonEnv}/${pythonEnv.python.sitePackages} "
        (regPlace "CLOUDSDK_PYTHON [^\\]+" "CLOUDSDK_PYTHON ${prev.lib.getExe pythonEnv.python} " old.installPhase));
  in {
    # this is my weird hack, otherwise ${pythonEnv} would not come into existance in the nix-store
    buildInputs = [pythonEnv];
    installPhase = installPhase';
  });

  # recent micromamba
  micromamba = prev.micromamba.overrideAttrs (old:
    # inspired by: https://github.com/NixOS/nixpkgs/commit/aff821e3a5a605f930e089630f4cbaf8067e6b54
    let
      libsolv' = prev.libsolv.overrideAttrs (oldAttrs: {
        cmakeFlags =
          oldAttrs.cmakeFlags
          ++ [
            "-DENABLE_CONDA=true"
          ];

        patches = [
          # Apply the same patch as in the "official" boa-forge build:
          # https://github.com/mamba-org/boa-forge/tree/master/libsolv
          (prev.fetchpatch {
            url = "https://raw.githubusercontent.com/mamba-org/boa-forge/20530f80e2e15012078d058803b6e2c75ed54224/libsolv/conda_variant_priorization.patch";
            sha256 = "1iic0yx7h8s662hi2jqx68w5kpyrab4fr017vxd4wyxb6wyk35dd";
          })
        ];
      });

      spdlog' = prev.spdlog.overrideAttrs (oldAttrs: {
        # Use as header-only library.
        #
        # Spdlog 1.11 requires fmt version 8 while micromamba requires
        # version 9. spdlog may use its bundled version of fmt,
        # though. Micromamba is not calling spdlog functions with
        # fmt-types in their signature. I.e. we get away with removing
        # fmt_8 from spdlog's propagated dependencies and using fmt_9 for
        # micromamba itself.
        dontBuild = true;
        cmakeFlags = oldAttrs.cmakeFlags ++ ["-DSPDLOG_FMT_EXTERNAL=OFF"];
        propagatedBuildInputs = [];
      });
      patches =
        [
          # https://github.com/mamba-org/mamba/pull/2397
          (prev.fetchpatch {
            url = "https://github.com/mamba-org/mamba/commit/6cf90892bf73c7c479def3b2da4fe1d2077c1a72.patch";
            sha256 = "sha256-fuUGf4NJ9pL+X7z8CxWYJxzwHTH/cgxINmaOYZ9bc+M=";
          })
        ]
        ++ old.patches or [];

      version = "1.4.0";
    in {
      inherit version;
      src = prev.fetchFromGitHub {
        owner = "mamba-org";
        repo = "mamba";
        rev = "micromamba-" + version;
        sha256 = "sha256-CnsECmquB3gt5N6lTjJ7A34DM6H4Neqb7URVgQzgnYk=";
      };
      inherit patches;

      # removed termcolor since it was removed upstream
      buildInputs = with prev; [
        bzip2
        cli11
        nlohmann_json
        curl
        libarchive
        yaml-cpp
        libsolv'
        reproc
        spdlog'
        ghc_filesystem
        python3
        tl-expected
        fmt_9
      ];
    });

  # ruff-lsp from: https://github.com/kalekseev/dotfiles/blob/f79db5e662915143c617934e9097b1c8956aa7c7/nixpkgs/overlays/my-packages.nix#L38
  ruff-lsp = let
    pkgs = prev.python3.pkgs;
  in
    pkgs.buildPythonPackage
    rec {
      pname = "ruff-lsp";
      version = "0.0.23";
      format = "pyproject";
      disabled = pkgs.pythonOlder "3.7";

      src = pkgs.fetchPypi {
        inherit version;
        pname = "ruff_lsp";
        sha256 = "sha256-T+hsEXwW+4KEcaAKttpLIZvFt9k7eLMFPiY2FOQV4L8=";
      };

      nativeBuildInputs = [
        pkgs.hatchling
        pkgs.pythonRelaxDepsHook
      ];

      pythonRemoveDeps = ["ruff" "lsprotocol"];
      propagatedBuildInputs = [
        pkgs.pygls
        pkgs.typing-extensions
      ];

      postPatch = ''
        sed -i 's|GLOBAL_SETTINGS: dict\[str, str\] = {}|GLOBAL_SETTINGS: dict[str, str] = {"path": ["${prev.ruff}/bin/ruff"]}|' ruff_lsp/server.py
      '';

      meta = with prev.lib; {
        homepage = "https://github.com/charliermarsh/ruff-lsp";
        description = "A Language Server Protocol implementation for Ruff";
        license = licenses.mit;
        maintainers = with maintainers; [kalekseev];
      };
    };

  # recent and updating querystream from file
  pspg = prev.pspg.overrideAttrs (old: {
    version = "5.7.5-rc";
    src = prev.fetchFromGitHub {
      owner = "okbob";
      repo = old.pname;
      rev = "f7550a34fde06e65a9d1ed6b6c4cd20f0a2853cb";
      sha256 = "sha256-5XHT3Z40PUPO0c6bghDX547E6uEhBLZ6uRhJObVQazo";
    };
    patches = prev.patches or [] ++ [../patches/pspg.patch];
  });
}
