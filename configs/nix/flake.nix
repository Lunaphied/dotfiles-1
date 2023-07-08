{
  description = "Computers with the nixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    polkadots = {
      url = "github:lf-/polkadots";
      flake = false;
    };
    aiobspwm = {
      url = "github:lf-/aiobspwm";
      flake = false;
    };
    aiopanel = {
      url = "github:lf-/aiopanel";
      flake = false;
    };

    nixGL = {
      url = "github:guibou/nixGL";
      # I don't like their flake
      flake = false;
    };

    gitignore = {
      url = "github:hercules-ci/gitignore";
      flake = false;
    };

    # my displeasure is hardly measurable
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, polkadots, aiobspwm, aiopanel, flake-utils, gitignore, ... }:
    let dep-inject = {
      jade.dep-inject = {
        inherit polkadots aiobspwm aiopanel gitignore;
      };
    };
    in
    {
      inherit nixpkgs inputs;
      np = nixpkgs.path;
      nixosConfigurations.snowflake = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/snowflake
          ./modules/dep-inject.nix
          dep-inject
        ];
      };
      nixosConfigurations.micro = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/micro
          ./modules/dep-inject.nix
          dep-inject
        ];
      };

      packages.x86_64-linux =
        let
          aiopanel = /home/jade/dev/aiopanel;
          pkgs = import nixpkgs {
            overlays = [
              (import ./overlays/aiopanel.nix { inherit aiobspwm aiopanel; })
              (import ./overlays/gitignore.nix { gitignore = inputs.gitignore; })
              (import ./overlays/jadeware.nix)
            ];
            system = "x86_64-linux";
          };
        in
        {
          inherit (pkgs) aiopanel vim-swapfile-header nvimsplit nvremote;
        };
    };
}
