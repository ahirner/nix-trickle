final: prev: {
  # recent and updating querystream from file
  pspg = prev.pspg.overrideAttrs (old: {
    inherit (old) src meta;
    version = "5.8.12-patched";
    patches = prev.patches or [] ++ [../patches/pspg.patch];
  });
}
