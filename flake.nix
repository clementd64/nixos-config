{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Rollback Go 1.20.6 to mitigate a upstream Docker bug https://github.com/moby/moby/issues/45935
    nixpkgs-docker.url = github:NixOS/nixpkgs?rev=b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc;

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

        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

        specialArgs = {
          inherit inputs pkgs-unstable;
        };

        overlays = [
          (import ./overlays/hashicorp.nix)
          (import ./overlays/kubernetes.nix)
          (import ./overlays/traefik.nix)
          (import ./overlays/docker.nix {
            inherit system pkgs-unstable;
            inherit (inputs) nixpkgs-docker;
          })
        ];
      in nixpkgs.lib.nixosSystem {
        inherit system specialArgs;

        modules = [
          # Custom modules
          { imports = module-list.system; }

          # Overlays
          { nixpkgs.overlays = overlays; }

          home-manager.nixosModule
          ./hardware/${name}.nix
          ./hosts/${name}/system.nix
          {
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
            };
            nixpkgs.config.allowUnfree = true;

            networking.hostName = name;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.clement = {
              imports = module-list.home ++ [ ./hosts/${name}/home.nix ];
            };
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
