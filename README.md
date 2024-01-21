[![CI](https://github.com/ahirner/nix-trickle/actions/workflows/ci.yml/badge.svg)](https://github.com/ahirner/nix-trickle/actions/workflows/ci.yml)
# nix-trickle

`nix-trickle` provides for the post-modern developer ™️.

## Use

Explore outputs:

```sh
$ nix develop
exes: gcloud==452.0.1 pspg==5.8.0-patched rustc==1.73.0
$ nix repl
nix-repl> :lf .
```

Example devShell following `nix-trickle`: ❄️

```
nix flake init -t github:ahirner/nix-trickle#devShell
```

## Outputs

### `overlays` ❄️

- nixpkgs/google-cloud-sdk: fixed `gsutil`, [cf](https://github.com/NixOS/nixpkgs/issues/67094#issuecomment-1148856771)
- nixpkgs/[pspg](https://github.com/okbob/pspg): updates querystream on file changes (--querystream -f query.sql)
- nixpkgs: all overlays above
- default = nixpkgs


### `systems`

List of systems CI checks are run on.


### `packages` ❄️

Packages with overlays for `systems`.


### `devShells` ❄️

- default: all `packages` in PATH


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
