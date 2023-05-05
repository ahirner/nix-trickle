{
  description = "Flake aggregation for the post-modern developer (tm)";

  inputs = {
    # "recent" nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/0e19daa510e47a40e06257e205965f3b96ce0ac9";

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
      inputs.fenix.follows = "fenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeCompat.follows = "flake-compat";
    };

    # buildtools
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-pre-commit.follows = "flake-utils";
      inputs.flake-parts.follows = "parts";
      inputs.drv-parts.follows = "drv-parts";
      inputs.flake-compat.follows = "flake-compat";
    };
    nci = {
      # newer commits break with missing .lib
      url = "github:yusdacra/nix-cargo-integration";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.dream2nix.follows = "dream2nix";
      inputs.parts.follows = "parts";
    };
    cargo2nix = {
      # some fixes "only" for garage...
      # https://git.deuxfleurs.fr/Deuxfleurs/garage/src/branch/main/flake.nix
      url = "github:Alexis211/cargo2nix/a7a61179b66054904ef6a195d8da736eaaa06c36";
      #url = "github:cargo2nix/cargo2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-compat.follows = "flake-compat";
    };

    # packages
    garage = {
      # tarball errors with missing self.lastModifiedDate
      url = "git+https://git.deuxfleurs.fr/Deuxfleurs/garage.git?rev=1ecd88c01f0857139921214a264128e5639e31db";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.cargo2nix.follows = "cargo2nix";
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
      (final: prev: {
        ruff = prev.ruff.overrideAttrs (old: {
          # cache.nixos.org produces invalid darwin binaries?
          # /nix/store/vrxifpk5bhdgrq28qn9yna63c4w62v08-ruff-0.0.259/bin/ruff
          # Illiegal instruction: 4
          doCheck = true;
        });
      })
      (import ./overlays)
      # go directly with flake input
      (_: prev: {garage = inputs.garage.packages.${prev.pkgs.system}.default;})
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
