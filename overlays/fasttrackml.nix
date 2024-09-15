final: prev: let
  inherit (prev) lib fetchFromGitHub;
  buildGoModule = prev.buildGoModule;
in {
  fasttrackml = buildGoModule rec {
    pname = "fasttrackml";
    version = "0.7.0-rc";

    src = fetchFromGitHub {
      owner = "G-Research";
      repo = pname;
      rev = "9cdfa3dd38ae00ec990aea1511afe666637daa2f";
      hash = "sha256-SHCfpMjQEkbZj+u793oO4j9ejQJEoZ4q/u2TrhHBfms=";
    };
    vendorHash = "sha256-3Yxx1zdb+0cbFIzEE+xVb09TeAKYmC5Y//rVtp+iwZ0=";
    tags = builtins.split "," (builtins.readFile "${src}/.go-build-tags");
    ldflags = ["-s" "-w" "-X main.Commit=${version}"];
    # can't get it to skip:
    checkFlags = ["-skip=^TestImportTestSuite*"];
    doCheck = false;
    meta = {
      description = "Experiment tracking server focused on speed and scalability";
      homepage = "https://fasttrackml.io";
      license = lib.licenses.asl20;
      maintainers = [];
    };
  };
}
