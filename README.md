[![CI](https://github.com/ahirner/nix-trickle/actions/workflows/ci.yml/badge.svg)](https://github.com/ahirner/nix-trickle/actions/workflows/ci.yml)
# nix-trickle

`nix-trickle` provides for the post-modern developer ™️.

## Use

Explore outputs:

```sh
nix develop -c repl .
nix-repl> outputs.pkgs.<TAB>
outputs.pkgs.aarch64-linux  outputs.pkgs.x86_64-linux
outputs.pkgs.x86_64-darwin
nix-repl> pkgs.taplo.version
"0.8.1-rc"
```

Example devShell following `nix-trickle`: ❄️

```nix
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
```


## Outputs

### `overlays` ❄️

- nixpkgs/[taplo](https://taplo.tamasfe.dev): [fixes lsp exit](https://github.com/tamasfe/taplo/pull/354) 
- nixpkgs/google-cloud-sdk: fixed `gsutil`, [cf](https://github.com/NixOS/nixpkgs/issues/67094#issuecomment-1148856771)
- nixpkgs/[cloud-sql-proxy_2](https://github.com/GoogleCloudPlatform/cloudsql-proxy): v2 of cloud-sql-proxy
- nixpkgs/[pspg](https://github.com/okbob/pspg): updates querystream on file changes (--querystream -f query.sql)
- nixpkgs: all overlays above
- default = nixpkgs


### `packages` ❄️

All package overlays are directly available as package for supported systems.


### `devShells` ❄️

- repl = default: `nix repl` with loaded flake, see [flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus)
- packages: all `packages`


### `lib.mkFlake`

🚧


### `pkgs.nixpkgs`

`nixpkgs` unstable with applied overlays. In that way, a derived system can register
`nix-trickle.pkgs` as `nixpkgs` and obtain equal store paths for `flake`
and regular `nix` commands.

To start using these packages as the sole source for a system:

```
nix flake init -t github:ahirner/nix-trickle#pure-system
```

### `templates` ❄️

- pure-system: Example configuration for pure flake systems based on `nix-trickle`
- devShell: Example devShell based on `nix-trickle`


### `nixosModules` ❄️

- bin-cache: add substituter and public key to `nix.settings` of cached package builds
