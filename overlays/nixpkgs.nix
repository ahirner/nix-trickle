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
  micromamba = prev.micromamba.overrideAttrs (
    let
      version = "1.5.1";
    in
      old: {
        inherit version;
        src = prev.fetchFromGitHub {
          owner = "mamba-org";
          repo = "mamba";
          rev = "micromamba-" + version;
          hash = "sha256-cKCK7lBlqRSfNSDPeGCP2yzoFvbtVmdFMATIkkDEwg4=";
        };
        meta = old.meta // {mainProgram = old.pname;};
      }
  );
  edgedb = let
    old = prev.edgedb;
    version = "4.0.2";
  in
    prev.rustPlatform.buildRustPackage rec {
      inherit version;
      inherit (old) pname buildInputs nativeBuildInputs patches checkFeatures doCheck passthru meta;
      src = prev.fetchFromGitHub {
        owner = "edgedb";
        repo = "edgedb-cli";
        rev = "v${version}";
        sha256 = "sha256-uilotat61U6jW1NLh7fVHOujkzUSFRdpeOx+ECGsByY=";
        fetchSubmodules = true;
      };
      #cargoHash = "";
      cargoLock = {
        lockFile = "${src}/Cargo.lock";
        outputHashes = {
          "edgedb-derive-0.5.1" = "sha256-1tbWg3bLab3xlVQxb4G+kpXriO+zQpnrwAESy5Tqsu4=";
          "edgeql-parser-0.1.0" = "sha256-c5xBuW47xXgy8VLR/P7DvVhLBd0rvI6P9w82IPPsTwo=";
          "indexmap-2.0.0-pre" = "sha256-QMOmoUHE1F/sp+NeDpgRGqqacWLHWG02YgZc5vAdXZY=";
          "rexpect-0.5.0" = "sha256-vstAL/fJWWx7WbmRxNItKpzvgGF3SvJDs5isq9ym/OA=";
          "rustyline-8.0.0" = "sha256-CrICwQbHPzS4QdVIEHxt2euX+g+0pFYe84NfMp1daEc=";
          "serde_str-1.0.0" = "sha256-CMBh5lxdQb2085y0jc/DrV6B8iiXvVO2aoZH/lFFjak=";
        };
      };
    };
  # recent and updating querystream from file
  pspg = prev.pspg.overrideAttrs (old: {
    version = "5.8.0-patched";
    src = prev.fetchFromGitHub {
      owner = "okbob";
      repo = old.pname;
      rev = "1e0028d9d0c17b0956f844205211cf6d9a92b456";
      hash = "sha256-apcvYonFl8+vJ7CPBs8f1UA+bD63TchA5++Td+RNQHY=";
    };
    patches = prev.patches or [] ++ [../patches/pspg.patch];
    meta = old.meta // {mainProgram = old.pname;};
  });
}
