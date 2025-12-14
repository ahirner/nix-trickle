final: prev: let
  supersetBase = prev.python3.pkgs.callPackage ./superset/default.nix {};
  supersetEnv = prev.python3.withPackages (ps: [
    supersetBase
    ps.granian
  ]);
in {
  superset = supersetBase.overrideAttrs (old: {
    passthru =
      (old.passthru or {})
      // {
        granian = prev.writeShellScriptBin "superset-granian" ''
          export PATH=${supersetEnv}/bin:$PATH
          exec ${supersetEnv}/bin/python -m granian --factory --interface wsgi "superset.app:create_app" "$@"
        '';
      };
  });
}
