final: prev: let
  superset = final.superset;
  supersetEnv = prev.python3.withPackages (ps: [
    superset
    ps.granian
  ]);
  script = prev.writeShellScriptBin "superset-granian" ''
    export PATH=${supersetEnv}/bin:$PATH
    exec ${supersetEnv}/bin/python -m granian --factory --interface wsgi "superset.app:create_app" "$@"
  '';
in {
  superset-granian = prev.symlinkJoin {
    inherit (superset) version;
    name = "superset-granian-${superset.version}";
    paths = [script supersetEnv];
    meta.mainProgram = "superset-granian";
  };
}
