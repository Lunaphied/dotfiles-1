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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "flake-utils";
      inputs.darwin.follows = "flake-utils";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    flakey-profile = {
      url = "github:lf-/flakey-profile";
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

  outputs =
    inputs@{ self
    , nixpkgs
    , polkadots
    , aiobspwm
    , aiopanel
    , flake-utils
    , gitignore
    , agenix
    , lanzaboote
    , flakey-profile
    , ...
    }:
    let
      dep-inject = {
        imports = [ lanzaboote.nixosModules.lanzaboote ];
        jade.dep-inject = {
          inherit polkadots aiobspwm aiopanel gitignore nixpkgs;
        };
      };
    in
    {
      inherit nixpkgs inputs;
      np = builtins.storePath nixpkgs.path;
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
      nixosConfigurations.voracle = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./machines/voracle
          ./modules/dep-inject.nix
          dep-inject
        ];
      };
      nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./roles/iso ];
      };
      nixosConfigurations.cube = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/cube
          ./modules/dep-inject.nix
          dep-inject
          agenix.nixosModules.default
        ];
      };

      devShells.x86_64-linux =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixos-rebuild
              agenix.packages.${system}.default
              rage
            ];
          };
        };

      packages.x86_64-linux =
        let
          aiopanel = /home/jade/dev/aiopanel;
          pkgs = import nixpkgs {
            overlays = [
              (import ./overlays/aiopanel.nix { inherit aiobspwm aiopanel; })
              (import ./overlays/gitignore.nix { gitignore = inputs.gitignore; })
              (import ../../programs/hsutils/overlay.nix { ghcVer = "ghc94"; })
              (import ./overlays/jadeware.nix)
            ];
            system = "x86_64-linux";
          };
        in
        {
          inherit (pkgs) aiopanel vim-swapfile-header nvimsplit nvremote;
          iso = self.nixosConfigurations.iso.config.system.build.isoImage;

          profile = import ./profile.nix { inherit pkgs flakey-profile nixpkgs; };
          system-profile = import ./system-profile.nix { inherit pkgs flakey-profile; };
        };
    };
}
