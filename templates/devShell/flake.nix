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
      checks = with pkgs;
        {
          inherit micromamba grafana;
          helix = helix.packages.${system}.default;
        }
        // lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
          wine = wineWow64Packages.staging;
        }
        // lib.optionalAttrs (stdenv.hostPlatform.system == "aarch64-darwin") {
          wine = pkgs.pkgsx86_64Darwin.wineWow64Packages.staging;
        };
    in {
      inherit checks;
      devShells.default = pkgs.mkShell {
        packages = builtins.attrValues checks;
      };
    });
}
