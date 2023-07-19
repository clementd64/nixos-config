{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixpkgs-unstable, ... }@inputs:
  let
    module-list = import ./modules;

    mkSystem = { system, name }:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      in nixpkgs.lib.nixosSystem {
        inherit system specialArgs;

        modules = [
          home-manager.nixosModule
          { imports = module-list.system; }
          ./hardware/${name}.nix
          ./hosts/${name}/system.nix
          {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nixpkgs.config.allowUnfree = true;

            networking.hostName = name;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.clement = {
              imports = module-list.home ++ [ ./hosts/${name}/home.nix ];
            };
          }
          # Update Docker
          {
            nixpkgs.overlays = [ (final: prev: {
              docker = (pkgs.callPackage ./overlay/docker.nix {}).docker_24_0;
            }) ];
          }
        ];
      };

    hosts = {
      alfeto = {
        system = "x86_64-linux";
      };

      syra = {
        system = "x86_64-linux";
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: value: mkSystem (value // { inherit name; })) hosts;
  };
}
