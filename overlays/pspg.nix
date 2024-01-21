final: prev: {
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
