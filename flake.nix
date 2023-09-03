{
  description = "Flake aggregation for the post-modern developer (tm)";

  inputs = {
    # hydra: https://status.nixos.org
    # nixos-unstable 2023-08-01
    # tests: https://hydra.nixos.org/job/nixos/trunk-combined/tested#tabs-status
    nixpkgs.url = "github:NixOS/nixpkgs/aa8aa7e2ea35ce655297e8322dc82bf77a31d04b";

    # utils
    utils = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    drv-parts = {
      url = "github:davhau/drv-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "parts";
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
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.flake-parts.follows = "parts";
      inputs.drv-parts.follows = "drv-parts";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs = inputs @ {
    utils,
    self,
    ...
  }: let
    overlays = [
      inputs.rust-overlay.overlays.default
      (import ./overlays)
    ];

    /*
     Builds a flake with aggregated inputs and some options.

    Based on: mkFlake in https://github.com/gytis-ivaskevicius/flake-utils-plus
    */
    lib = inputs.nixpkgs.lib;
    mkFlake = {
      self,
      inputs,
      hosts ? {},
      extraOverlays ? [],
      extraDefaultModules ? [],
      sharedConfigOverride ? {},
      outputsBuilder ? _: {},
      ...
    } @ args: let
      # remove although they are anyway
      moreArgs = builtins.removeAttrs args [
        "extraOverlays"
        "extraDefaultModules"
        "sharedConfigOverride"
      ];
      flakeMake =
        moreArgs
        // {
          inherit self inputs;
          sharedOverlays = overlays ++ extraOverlays;
          channelsConfig = {allowUnfree = true;} // sharedConfigOverride;

          hostDefaults.modules =
            [
              {
                nix.generateRegistryFromInputs = lib.mkDefault true;
                nix.generateNixPathFromInputs = lib.mkDefault true;
                nix.linkInputs = lib.mkDefault true;
                nix.settings.experimental-features = ["nix-command" "flakes"];
              }
            ]
            ++ extraDefaultModules;

          # 1to1 outputs, hosts
          inherit outputsBuilder hosts;
        };
    in
      utils.lib.mkFlake flakeMake;
  in
    mkFlake
    {
      inherit self inputs;
      supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin"];

      # utils assisted outputs
      outputsBuilder = channels: let
        # all nixpgs
        pkgs = channels.nixpkgs;
        # all packages for which overlays were defined
        packages = utils.lib.exportPackages self.overlays channels;
      in {
        formatter = pkgs.alejandra;
        devShells.default = with pkgs;
          mkShell {
            name = "repl";
            description = "`nix repl` loaded with system or flake argument";
            nativeBuildInputs = [
              fup-repl
              alejandra
            ];
          };
        devShells.packages = with pkgs;
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

      # export customized mkFlake
      lib.mkFlake = mkFlake;
    }
    // {
      # custom overlays from inputs
      overlays =
        utils.lib.exportOverlays {inherit (self) pkgs;}
        // rec {
          nixpkgs = final: prev:
            lib.composeManyExtensions overlays final prev;
          default = nixpkgs;
        };
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
}
