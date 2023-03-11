{
  description = "Flake aggregation for the post-modern developer (tm)";

  inputs = {
    # "recent" unstable and working well
    nixpkgs.url = "github:NixOS/nixpkgs/a1291d0d020a200c7ce3c48e96090bfa4890a475";

    # utils
    utils = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # tools
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.fenix.follows = "fenix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.alejandra.follows = "alejandra";
    };
    nci = {
      # newer commits break with missing .lib
      url = "github:yusdacra/nix-cargo-integration/b1b0d38b8c3b0d0e6a38638d5bbe10b0bc67522c";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.dream2nix.follows = "dream2nix";
      inputs.devshell.follows = "dream2nix/devshell";
    };
    cargo2nix = {
      # some fixes "only" for garage...
      # https://git.deuxfleurs.fr/Deuxfleurs/garage/src/branch/main/flake.nix
      url = "github:Alexis211/cargo2nix/a7a61179b66054904ef6a195d8da736eaaa06c36";
      #url = "github:cargo2nix/cargo2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-compat.follows = "alejandra/flakeCompat";
    };

    # packages
    garage = {
      # tarball errors with missing self.lastModifiedDate
      url = "git+https://git.deuxfleurs.fr/Deuxfleurs/garage.git?tag=v0.8.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.cargo2nix.follows = "cargo2nix";
    };

  };

  outputs = inputs @{ utils, self, ... }:
    let
      overlays = [
        inputs.rust-overlay.overlays.default
        (import ./overlays)
        # go directly with flake input
        (_: prev: { garage = inputs.garage.packages.${prev.pkgs.system}.default; })
      ];

      /* Builds a flake with aggregated inputs and some options.
      
        Based on: mkFlake in https://github.com/gytis-ivaskevicius/flake-utils-plus
      */
      lib = inputs.nixpkgs.lib;
      mkFlake =
        { self
        , inputs
        , hosts ? { }
        , extraOverlays ? [ ]
        , extraDefaultModules ? [ ]
        , sharedConfigOverride ? { }
        , outputsBuilder ? _: { }
        , ...
        }@args:
        let
          # remove although they are anyway
          moreArgs = (builtins.removeAttrs args [
            "extraOverlays"
            "extraDefaultModules"
            "sharedConfigOverride"
          ]);
          flakeMake = moreArgs // {
            inherit self inputs;
            sharedOverlays = overlays ++ extraOverlays;
            channelsConfig = { allowUnfree = true; } // sharedConfigOverride;

            hostDefaults.modules = [
              {
                nix.generateRegistryFromInputs = lib.mkDefault true;
                nix.generateNixPathFromInputs = lib.mkDefault true;
                nix.linkInputs = lib.mkDefault true;
                nix.settings.experimental-features = [ "nix-command" "flakes" ];
              }
            ] ++ extraDefaultModules;

            # 1to1 outputs, hosts 
            inherit outputsBuilder hosts;
          };
        in
        utils.lib.mkFlake flakeMake;
    in
    mkFlake
      {
        inherit self inputs;
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];

        # utils assisted outputs
        outputsBuilder = channels:
          let
            pkgs = channels.nixpkgs;
          in
          {
            devShells.default = with pkgs; mkShell {
              name = "repl";
              nativeBuildInputs = [
                fup-repl
                alejandra
              ];
            };
            formatter = pkgs.alejandra;

            # export all packages for which overlays were defined
            packages = utils.lib.exportPackages self.overlays channels;
          };

        # export customized mkFlake
        lib.mkFlake = mkFlake;
      } // {
      # custom overlays from inputs
      overlays = utils.lib.exportOverlays { inherit (self) pkgs; } // rec {
        nixpkgs = final: prev:
          lib.composeManyExtensions overlays final prev;
        default = nixpkgs;
      };
    };
}
