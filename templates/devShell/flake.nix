{
  inputs = {
    nix-trickle.url = "github:ahirner/nix-trickle";
    helix = {
      url = "github:helix-editor/helix";
      inputs.flake-utils.follows = "nix-trickle/flake-utils";
      inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
      inputs.rust-overlay.follows = "nix-trickle/rust-overlay";
    };
  };
  outputs = {
    nix-trickle,
    helix,
    ...
  }: {
    devShells =
      builtins.mapAttrs
      (system: channel: let
        pkgs = channel.nixpkgs;
        packages = [
          pkgs.micromamba
          helix.packages.${system}.default
        ];
      in {
        default = pkgs.mkShell {inherit packages;};
      })
      nix-trickle.pkgs;
  };
}
