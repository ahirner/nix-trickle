{
  inputs = {
    nix-trickle.url = "github:ahirner/nix-trickle";
    flake-parts.follows = "nix-trickle/flake-parts";
    helix = {
      url = "github:helix-editor/helix";
      inputs.flake-utils.follows = "nix-trickle/flake-utils";
      inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
      inputs.rust-overlay.follows = "nix-trickle/rust-overlay";
    };
  };
  outputs = inputs @ {
    flake-parts,
    nix-trickle,
    helix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [nix-trickle.flakeModules.flakeDefaults];
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        checks = with pkgs; {
          inherit micromamba grafana vector;
          wine = wineWow64Packages.staging;
          helix = helix.packages.${system}.default;
        };
      in {
        inherit checks;
        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues checks;
        };
      };
    };
}
