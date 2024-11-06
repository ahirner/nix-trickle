final: prev: let
  pkgs = prev;
in {
  vector =
    if !pkgs.stdenv.isDarwin
    then pkgs.vector
    else
      pkgs.vector.overrideAttrs (old: {
        # krb5-src needs mig
        nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.darwin.bootstrap_cmds];
      });
}
