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
    };

    # buildtools
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
    risingwave.url = "github:risingwavelabs/risingwave";
    risingwave.flake = false;
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    crane,
    ...
  }: let
    lib = inputs.nixpkgs.lib;
    overlayAttrs = import ./overlays.nix {inherit lib;};
    overlays = (builtins.attrValues overlayAttrs) ++ [(import inputs.rust-overlay)];
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
        # pin nightly for ahash https://users.rust-lang.org/t/error-e0635-unknown-feature-stdsimd/106445/2
        rustWithWasiTarget = pkgs.rust-bin.nightly."2024-02-04".default.override {
          targets = ["wasm32-wasi"];
        };
        craneLib = (crane.mkLib pkgs).overrideToolchain rustWithWasiTarget;
        risingwave = craneLib.buildPackage {
          pname = "risingwave";
          version = "1.7.0";
          src = craneLib.cleanCargoSource (craneLib.path inputs.risingwave.outPath);
          strictDeps = true;
          patches = [./patches/risingwave.patch];
          nativeBuildInputs = with pkgs; [
            krb5
            openssl.dev
            pkg-config
          ];
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          OPENSSL_NO_VENDOR = 1;
          buildInputs =
            []
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
            ];
        };
        packages = (builtins.mapAttrs (name: _: builtins.getAttr name pkgs) overlayAttrs) // {inherit risingwave;};
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
