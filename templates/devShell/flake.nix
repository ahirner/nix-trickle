{
  inputs = {
    nix-trickle.url = "github:ahirner/nix-trickle";
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
      inputs.rust-overlay.follows = "nix-trickle/rust-overlay";
      inputs.nci.follows = "nix-trickle/nci";
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
