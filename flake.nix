{
  description = "Flake aggregation for the post-modern developer (tm)";

  inputs = {
    # hydra: https://status.nixos.org
    # tests: https://hydra.nixos.org/job/nixos/trunk-combined/tested#tabs-status
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # tools
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeCompat.follows = "flake-compat";
      inputs.fenix.follows = "fenix";
    };
    # buildtools
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }: let
    lib = inputs.nixpkgs.lib;
    overlayAttrs = (import ./overlays.nix {inherit lib;}) // {rustc = inputs.rust-overlay.overlays.default;};
    overlays = builtins.attrValues overlayAttrs;
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin"];

    flakeDefaults = {
      inherit systems;
      perSystem = {
        system,
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system overlays;
        };
      };
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      inherit systems;
      imports = [flakeDefaults];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        packages = builtins.mapAttrs (name: _: builtins.getAttr name pkgs) overlayAttrs;
      in {
        devShells.default = with pkgs;
          mkShell {
            name = "pkgs";
            description = "all packages";
            nativeBuildInputs = builtins.attrValues packages;
            shellHook = let
              versions =
                builtins.toString (builtins.map (p: "${builtins.baseNameOf (lib.getExe p)}==${p.version}")
                  (builtins.attrValues packages));
            in ''
              echo exes: ${versions}
            '';
          };
        # export all packages for which overlays were defined
        inherit packages;
      };

      flake = {
        lib,
        pkgs,
        ...
      }: {
        inherit systems;
        pkgs.nixpkgs = pkgs;
        flakeModules = {inherit flakeDefaults;};
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
              package = pkgs.nixUnstable;
              nixPath = ["nixpkgs=${self.inputs.nixpkgs}"]; # Enables use of `nix-shell -p ...` etc
              registry.nixpkgs.flake = self.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
              settings = {
                max-jobs = "auto";
                experimental-features = "nix-command flakes repl-flake";
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
    };
}
