final: prev: {
  # recent and updating querystream from file
  pspg = prev.pspg.overrideAttrs (old: {
    version = "5.8.7-patched";
    src = prev.fetchFromGitHub {
      owner = "okbob";
      repo = old.pname;
      rev = "refs/tags/5.8.7";
      hash = "sha256-SE+62EODKWcKFpMMbWDw+Dp5b2D/XKbMFiJiD/ObrhU=";
    };
    patches = prev.patches or [] ++ [../patches/pspg.patch];
    meta = old.meta // {mainProgram = old.pname;};
  });
}
