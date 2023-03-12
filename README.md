# nix-trickle

`nix-trickle` provides for the post-modern developer ™️.

## Use

Explore outputs:

```sh
nix develop -c repl .
nix-repl> outputs.pkgs.<TAB>
outputs.pkgs.aarch64-linux  outputs.pkgs.x86_64-linux
outputs.pkgs.x86_64-darwin
nix-repl> pkgs.micromamba.version
"1.3.1"
```

Example devShell following `nix-trickle`: ❄️

```nix
{
  inputs = {
    nix-trickle.url = "../..";
    helix = {
      url = "github:helix-editor/helix/c5c1b5af34fb3f217fce4bec5f7bb16369e59888";
      inputs.nixpkgs.follows = "nix-trickle/nixpkgs";
      inputs.rust-overlay.follows = "nix-trickle/rust-overlay";
      inputs.nci.follows = "nix-trickle/nci";
    };
  };
  outputs = inputs@{ self, nix-trickle, ... }:
    let
      system = "x86_64-darwin";
      pkgs = nix-trickle.pkgs."${system}".nixpkgs;
    in
    {
      devShells."${system}".default = pkgs.mkShell {
        packages = with pkgs;[
          micromamba
          inputs.helix.packages.${pkgs.system}.default
        ];
      };
    };
}
```


## Outputs

### `overlays` ❄️

- nixpkgs/[micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html): newer version
- nixpkgs/[garage](https://garagehq.deuxfleurs.fr): newever version
- nixpkgs/[ruff-lsp](https://github.com/charliermarsh/ruff-lsp): added
- nixpkgs/google-cloud-sdk: fixed `gsutil`, [cf](https://github.com/NixOS/nixpkgs/issues/67094#issuecomment-1148856771)
- nixpkgs: all overlays above
- default = nixpkgs


### `packages` ❄️

All package overlays are directly available as package for supported systems.


### `devShells` ❄️

- repl = default: `nix repl` with loaded flake, see [flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus)


### `lib.mkFlake`

🚧


### `pkgs.nixpkgs`

`nixpkgs` unstable with applied overlays. In that way, a derived system can register
`nix-trickle.pkgs` as `nixpkgs` and obtain equal store paths for `flake`
and regular `nix` commands.

🚧


### `templates`

🚧
