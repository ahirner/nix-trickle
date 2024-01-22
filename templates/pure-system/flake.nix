{
  inputs.nix-trickle.url = "github:ahirner/nix-trickle";
  inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
  inputs.flake-parts.follows = "nix-trickle/flake-parts";
  inputs.darwin.url = "github:lnl7/nix-darwin";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nix-trickle,
    darwin,
    home-manager,
    ...
  }: let
    lib = nix-trickle.inputs.nixpkgs.lib;
    # hoists nixpgs with own packages such that those expressions are equivalent:
    # - nix-shell -p <package>           # also needs default.nix with all self.pkgs
    # - nix shell self#<package>
    # - nix shell nix-trickle#<package>  # if not added/overlayed by self
    pureSystem = {
      #nixpkgs.pkgs = lib.mkForce inputs.nixpkgs.legacyPackages.x86_64-linux;
      # symlink no /etc/nix/inputs/nixpkgs is already in NIX_PATH by mkFlake,
      # therefore overwrite nixpkgs with our source, including default.nix
      environment.etc."nix/inputs/nixpkgs".source = lib.mkForce self.outPath;
      # override nixpkgs registry also, if you want this equivalence:
      # - nix shell nixpkgs#<package>
      #nix.registry.nixpkgs.flake = lib.mkForce self;
    };
    hmDefaults = {
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = {inherit inputs;};
    };
    # minimal config to build a system
    bootableSystem = {
      nixpkgs.hostPlatform = "x86_64-linux";
      boot.loader.grub.devices = ["nodev"];
      fileSystems."/" = {
        device = "test";
        fsType = "ext4";
      };
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      # flakeDefaults needed due to similar error as in https://github.com/numtide/treefmt-nix/issues/78
      imports = [nix-trickle.flakeModules.flakeDefaults];
      # enable writing inputs/nixpkgs with self.outPath for default.nix
      perSystem = {pkgs, ...}: {legacyPackages = pkgs;};
      # systems
      flake = with nix-trickle.nixosModules; {
        nixosConfigurations = {
          purely = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              default
              bin-cache
              home-manager.nixosModules.home-manager
              hmDefaults
              bootableSystem
              pureSystem
            ];
          };
        };
        darwinConfigurations = {
          purely-darwin = darwin.lib.darwinSystem {
            modules = [
              default
              bin-cache
              home-manager.darwinModules.home-manager
              hmDefaults
              {nixpkgs.hostPlatform = "x86_64-darwin";}
              pureSystem
            ];
          };
        };
        # checks for integration tests, can be removed for casual use
        checks = {
          # breaks or breaks potentially due to: https://github.com/NixOS/nix/issues/4265
          x86_64-darwin.purely-darwin = self.darwinConfigurations.purely-darwin.system;
          x86_64-linux.purely = self.nixosConfigurations.purely.config.system.build.toplevel;
          # todo: test nix within configured system
          # todo: test default nix
        };
      };
    };
}
