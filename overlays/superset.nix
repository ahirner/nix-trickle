final: prev: let
  inherit (prev) lib;
  python3 = prev.python3;

  pname = "superset";
  version = "6.0.0rc4";
  src = prev.fetchFromGitHub {
    owner = "apache";
    repo = pname;
    rev = "${version}";
    hash = "sha256-lHHbSBSPT8UUAYmlpDHuwdhyy8u4/emydoPa9G8uXZ8=";
  };
in {
  superset = python3.pkgs.buildPythonApplication {
    inherit src pname version;

    pyproject = true;
    build-system = with python3.pkgs; [setuptools];

    meta = {
      description = "Data Visualization and Exploration Platform";
      homepage = "https://superset.apache.org";
      changelog = "https://github.com/apache/superset/blob/master/CHANGELOG/${version}.md"; # not for rc
      license = lib.licenses.asl20;
      mainProgram = "superset";
    };
  };
}
