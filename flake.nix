{
  description = "Flake aggregation for the post-modern developer (tm)";

  inputs = {
    # hydra: https://status.nixos.org
    # tests: https://hydra.nixos.org/job/nixos/trunk-combined/tested#tabs-status
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # buildtools
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {self, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin"];

    lib = inputs.nixpkgs.lib;
    overlayAttrs = (import ./overlays.nix {inherit lib;}) // {rustc = inputs.rust-overlay.overlays.default;};
    overlays = builtins.attrValues overlayAttrs;

    nixpkgs = lib.genAttrs systems (
      system:
        import inputs.nixpkgs {
          inherit system overlays;
        }
    );
    eachSystem' = fn: let
      perSystem = lib.genAttrs systems (system:
        fn {
          inherit system;
          pkgs = nixpkgs.${system};
        });
    in
      lib.mapAttrs (attr: _:
        lib.genAttrs systems (system: perSystem.${system}.${attr}))
      perSystem.${builtins.elemAt systems 0};
  in
    eachSystem' (
      {
        pkgs,
        system,
      }: {
        packages = builtins.mapAttrs (name: _: pkgs.${name}) overlayAttrs;
        formatter = pkgs.alejandra;
        devShells.default = let
          nativeBuildInputs = builtins.attrValues self.packages.${system};
        in
          with pkgs;
            mkShell {
              name = "pkgs";
              description = "all packages";
              inherit nativeBuildInputs;
              shellHook = let
                versions =
                  builtins.toString (builtins.map (p: "${builtins.baseNameOf (lib.getExe p)}==${p.version}")
                    nativeBuildInputs);
              in ''
                echo exes: ${versions}
              '';
            };
      }
    )
    // {
      images =
        lib.attrsets.mapAttrs' (
          name: package: let
            pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
          in
            lib.attrsets.nameValuePair
            name
            (pkgs.dockerTools.streamLayeredImage {
              contents = [pkgs.cacert pkgs.busybox];
              inherit name;
              tag = "latest";
              config = {Entrypoint = ["${lib.getExe package}"];};
            })
        )
        self.packages."x86_64-linux";

      inherit systems nixpkgs;
      lib.eachSystem' = eachSystem';

      # flake schema outputs
      # all overlays for independent consumption
      overlays = let
        nixpkgs = final: prev:
          lib.composeManyExtensions overlays final prev;
        default = nixpkgs;
      in (overlayAttrs // {inherit nixpkgs default;});

      # common modules related to `nix-trickle`
      nixosModules = {
        bin-cache = {
          nix.settings.substituters = ["https://cybertreiber.cachix.org"];
          nix.settings.trusted-public-keys = ["cybertreiber.cachix.org-1:Hk0+JJqAIfHY6J9/p5RFXvdHO35w/MgtT5BPVSzoCe0="];
        };
        default = {
          pkgs,
          lib,
          ...
        }: {
          # https://github.com/srid/nixos-config/blob/master/nixos/nix.nix
          nixpkgs = {
            config.allowUnfree = true;
            inherit overlays;
          };
          nix = {
            package = pkgs.nixVersions.latest;
            nixPath = ["nixpkgs=${self.inputs.nixpkgs}"]; # Enables use of `nix-shell -p ...` etc
            registry.nixpkgs.flake = self.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
            settings = {
              max-jobs = "auto";
              experimental-features = "nix-command flakes";
            };
          };
        };
      };
      # templates
      templates.pure-system = {
        path = ./templates/pure-system;
        description = "Example configuration for pure flake systems based on `nix-trickle`";
      };
      templates.devShell = {
        path = ./templates/devShell;
        description = "Example devShell based on `nix-trickle`";
      };
    };
}
