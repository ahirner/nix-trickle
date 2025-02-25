final: prev: let
  pkgs = prev;
  # https://github.com/gulrak/filesystem/issues/182
  ghc_filesystem' = pkgs.ghc_filesystem.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "gulrak";
      repo = "filesystem";
      rev = "master";
      hash = "sha256-v/7iOoWEkacU3rdaG/3UmsrpZRqb7wY9WrP8bEGTXYU=";
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
