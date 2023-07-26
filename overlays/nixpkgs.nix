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
  dioxus-cli = let
    old = prev.dioxus-cli;
  in
    prev.rustPlatform.buildRustPackage rec
    {
      inherit (old) meta pname buildInputs;
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [prev.cacert];
      version = "0.3.2";
      src = prev.fetchCrate {
        inherit version;
        inherit (old) pname;
        sha256 = "sha256-8S8zUOb2oiXbJQRgY/g9H2+EW+wWOQugr8+ou34CYPg=";
      };
      cargoSha256 = "sha256-sCP8njwYA29XmYu2vfuog0NCL1tZlsZiupkDVImrYCE=";
      checkFlags = [
        # would require dioxous binary in PATH, see: https://github.com/DioxusLabs/dioxus/pull/1138
        "--skip=cli::autoformat::spawn_properly"
        "--skip=cli::translate::generates_svgs"
      ];
    };
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
  # v2
  cloud-sql-proxy_2 = let
    version = "2.3.0";
    src = prev.fetchFromGitHub {
      owner = "GoogleCloudPlatform";
      repo = "cloudsql-proxy";
      rev = "v${version}";
      sha256 = "sha256-NT3PXUvOkcKS4FgKVb7kdI7Ic7w9D3rZiEM7dkQCojw=";
    };
  in
    # https://github.com/NixOS/nixpkgs/issues/86349
    prev.buildGoModule {
      pname = "cloud-sql-proxy_2";
      inherit src version;
      vendorSha256 = "sha256-o4EWCMd36iw69KifTK07LXj8HGK9wgidB6ZdaKxyLpw=";
      preCheck = ''
        buildFlagsArray+="-short"
      '';
      # requests fixed free ports like 5000
      # maybe related: https://github.com/GoogleCloudPlatform/cloud-sql-proxy/issues/1729
      doCheck = false;
      meta = prev.cloud-sql-proxy.meta // {mainProgram = "cloud-sql-proxy";};
    };
  # recent and updating querystream from file
  pspg = prev.pspg.overrideAttrs (old: {
    version = "5.7.6-rc";
    src = prev.fetchFromGitHub {
      owner = "okbob";
      repo = old.pname;
      rev = "9042608a0bababb1cd45a115ea23150041a837ff";
      sha256 = "sha256-A+O1ZbgkaJGWrBj8cSp/0UcilnGzfu0eW+4zgTCwaME=";
    };
    patches = prev.patches or [] ++ [../patches/pspg.patch];
  });
}
