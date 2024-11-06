final: prev: let
  pkgs = prev;
  # https://github.com/gulrak/filesystem/issues/182
  ghc_filesystem' = pkgs.ghc_filesystem.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "gulrak";
      repo = "filesystem";
      rev = "master";
      hash = "sha256-E6kJrNMHt3avjNwT4C0pTvnFbhyKsXMIP6NEfIl1m5Q=";
    };
  });
  micrombamba' = pkgs.micromamba.overrideAttrs (
    old: {
      buildInputs =
        (builtins.filter (x: x != prev.ghc_filesystem) old.buildInputs)
        ++ [
          ghc_filesystem'
        ];
    }
  );
in {
  micromamba =
    if !pkgs.stdenv.isDarwin
    then pkgs.micromamba
    else micrombamba';
}
