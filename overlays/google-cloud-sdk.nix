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
    # 23.3.0 removed OpenSSL.crypto.loads_pkcs12 which leads
    # to the same error as if pyopenssl is not installed (who programmed this?), warning:
    # PKCS#12 support in pyOpenSSL is deprecated. You should use the APIs in cryptography.
    python3 = prev.python3.override (old: {
      packageOverrides = self: super: {
        pyopenssl = super.pyopenssl.overridePythonAttrs (old: rec {
          nativeCheckInputs = old.nativeCheckInputs or [] ++ [prev.python3.pkgs.flaky];
          disabledTests =
            old.disabledTests
            ++ [
              "test_get_signature_algorithm"
              "test_get_undefined_signature_algorithm"
              "test_type_is_signed"
              "test_type_is_enveloped"
              "test_type_is_signed_and_enveloped"
              "test_type_is_data"
            ];
          version = "23.2.0";
          src = super.fetchPypi {
            pname = "pyOpenSSL";
            inherit version;
            hash = "sha256-J2+TH1WkUufeppxxc+mE6ypEB85BPJGKo0tV+C+bi6w=";
          };
        });
      };
    });
    # one cannot understand why python in old default.nix was magically python3...
    pythonEnv = python3.withPackages (p:
      with p; [
        cffi
        cryptography
        pyopenssl
        crcmod
        numpy
      ]);
    # give gcloud stuff the fixed python withPackages,
    # also remove alpha/beta modules (not needed and error with missing /nix/store)
    installPhase' =
      regPlace "cp /nix/store.*\__init__.py\n" ""
      (regPlace "PYTHONPATH : [^\\]+" "PYTHONPATH : ${pythonEnv}/${pythonEnv.python.sitePackages} "
        (regPlace "CLOUDSDK_PYTHON [^\\]+" "CLOUDSDK_PYTHON ${pythonEnv}/bin/python " old.installPhase));
  in {
    # this is my weird hack, otherwise ${pythonEnv} would not come into existance in the nix-store
    buildInputs = [pythonEnv];
    installPhase = installPhase';
  });
}
