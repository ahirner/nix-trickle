final: prev: {
  micromamba = prev.micromamba.overrideAttrs (
    old: {
      # doesn't matter :shrug: https://github.com/gulrak/filesystem/issues/182
      buildInputs = builtins.filter (x: x != prev.ghc_filesystem) old.buildInputs;
      src = prev.fetchFromGitHub {
        owner = "mamba-org";
        repo = "mamba";
        rev = "1.x";
        hash = "sha256-JdJ3ymDoiU/+r3UYFhyqG/TvDz9gBgKSdnrZS1369l8=";
      };
    }
  );
}
