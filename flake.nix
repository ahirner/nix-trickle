{
  description = "Flake aggregation for the post-modern developer (tm)";

  inputs = {
    # hydra: https://status.nixos.org
    # tests: https://hydra.nixos.org/job/nixos/trunk-combined/tested#tabs-status
    # instead latest release:
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

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
    };

    # buildtools
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

  outputs = inputs @ {flake-parts, ...}: let
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
    systemDefaults = {
      flake,
      pkgs,
      lib,
      ...
    }: {
      flake.nixOsModules.common = {
        # https://github.com/srid/nixos-config/blob/master/nixos/nix.nix
        nixpkgs = {
          inherit overlays;
          config.allowUnfree = true;
        };
        nix = {
          package = pkgs.nixUnstable;
          nixPath = ["nixpkgs=${flake.inputs.nixpkgs}"]; # Enables use of `nix-shell -p ...` etc
          registry.nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
          settings = {
            max-jobs = "auto";
            experimental-features = "nix-command flakes repl-flake";
            # Nullify the registry for purity.
            flake-registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}'';
          };
        };
      };
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      inherit systems;
      imports = [flakeDefaults systemDefaults];

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
        flakeModules = {
          inherit flakeDefaults systemDefaults;
        };

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
