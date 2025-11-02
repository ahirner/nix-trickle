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

- nixpkgs/[turso_cli](https://turso.tech): add turosdb bin
- nixpkgs/[spiced](https://docs.spiceai.org): add slim build of spiceai's Rust dameon
- nixpkgs/[sqruff](https://github.com/quarylabs/sqruff): newer
- nixpkgs/[pspg](https://github.com/okbob/pspg): updates querystream on file changes (--querystream -f query.sql)
- nixpkgs/[vector](https://vector.dev): fixes for darwin x86
- nixpgks/[micromamba](https://github.com/mamba-org/micromamba-releases): fixes for darwin
- nixpkgs: all overlays above
- default = nixpkgs

### `templates` ❄️

```
nix flake init -t github:ahirner/nix-trickle#pure-system
```

- pure-system: Example configuration for pure flake systems based on `nix-trickle`
- devShell: Example devShell based on `nix-trickle`


### `nixosModules` ❄️

- default: pure and modern `nix` system
- bin-cache: substituter and public key in `nix.settings` for `nix-trickle` builds


### `systems`

List of systems CI checks are run on.


### `nixpkgs`

Attribute set with all pkgs of nixpkgs and applied overlays per `system`.


### `packages` ❄️

Packages with overlays for all `systems`.


### `devShells` ❄️

- default: all `packages` in PATH


### `lib.eachSystem'`

Generate `${attr}{system}` given a `fn: {pkgs, system} -> attr`;

