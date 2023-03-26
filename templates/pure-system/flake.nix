{
  inputs.nix-trickle.url = "github:ahirner/nix-trickle";
  inputs.darwin.url = "github:lnl7/nix-darwin";
  inputs.nixpkgs.follows = "nix-trickle/nixpkgs";

  outputs = inputs' @ {
    self,
    nix-trickle,
    darwin,
    ...
  }: let
    lib = nix-trickle.inputs.nixpkgs.lib;
    inputs = nix-trickle.inputs // inputs';

    # hoists nixpgs with own packages such that those expressions are equivalent:
    # - nix-shell -p <package>           # also needs default.nix with all self.pkgs
    # - nix shell self#<package>
    # - nix shell nix-trickle#<package>  # if not added/overlayed by self
    pureSystem = {
      # symlink no /etc/nix/inputs/nixpkgs is already in NIX_PATH by mkFlake,
      # therefore overwrite nixpkgs with our source, including default.nix
      environment.etc."nix/inputs/nixpkgs".source = lib.mkForce self.outPath;
      # override nixpkgs registry also, if you want this equivalence:
      # - nix shell nixpkgs#<package>
      #nix.registry.nixpkgs.flake = lib.mkForce self;
    };
    # minimal config to build a system
    bootableSystem = {
      boot.loader.grub.devices = ["nodev"];
      fileSystems."/" = {
        device = "test";
        fsType = "ext4";
      };
    };
    # expose all of nix-trickle as legacyPackages:
    # - `nix flake check` doesn't fail eval without --legacy
    # - `nix shell` finds packages in self not added in self
    legacyPackages = builtins.mapAttrs (name: value: value.nixpkgs) nix-trickle.pkgs;
  in
    nix-trickle.lib.mkFlake {
      # self and inputs are required
      inherit self inputs legacyPackages;

      # add more default modules
      extraDefaultModules = [pureSystem nix-trickle.nixosModules.bin-cache];

      # add some own package
      outputsBuilder = channels: {
        packages.monad = channels.nixpkgs.writeShellScriptBin "mona" ''
          echo d
        '';
      };

      # example hosts
      hosts.purely = {
        modules = [bootableSystem]; # put per-system modules here
      };
      hosts.purely-darwin = {
        system = "x86_64-darwin";
        output = "darwinConfigurations";
        builder = darwin.lib.darwinSystem;
        modules = []; # put per-system modules here
      };

      # checks for integration tests, can be removed
      checks = {
        # breaks or breaks potentially due to: https://github.com/NixOS/nix/issues/4265 https://github.com/NixOS/nix/issues/6806
        x86_64-darwin.purely-darwin = self.darwinConfigurations.purely-darwin.system;
        x86_64-linux.purely = self.nixosConfigurations.purely.config.system.build.toplevel;
        # todo: test nix within configured system
        # todo: test default nix
      };
    };
}
