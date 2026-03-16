{
  inputs = {
    nix-trickle.url = "github:ahirner/nix-trickle";
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
    };
  };
  outputs = {
    nix-trickle,
    helix,
    ...
  }:
    nix-trickle.lib.eachSystem' ({
      pkgs,
      system,
    }: let
      checks = with pkgs; {
        inherit micromamba grafana vector;
        wine =
          if stdenv.hostPlatform.system == "aarch64-darwin"
          then pkgsx86_64Darwin.wineWow64Packages.staging
          else wineWow64Packages.staging;
        helix = helix.packages.${system}.default;
      };
    in {
      inherit checks;
      devShells.default = pkgs.mkShell {
        packages = builtins.attrValues checks;
      };
    });
}
