final: prev: let
  python = prev.python312.override {
    self = python;
    packageOverrides = import ./superset/dependencies.nix {
      inherit (prev) lib fetchPypi postgresql redisTestHook;
    };
  };
in {
  superset = python.pkgs.callPackage ./superset/default.nix {};
}
