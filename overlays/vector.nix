final: prev: {
  vector = prev.vector.overrideAttrs (old: {
    buildInputs =
      old.buildInputs
      or []
      ++ prev.lib.optionals
      prev.stdenv.isDarwin (with prev.pkgs; [darwin.apple_sdk.frameworks.SystemConfiguration]);
  });
}
