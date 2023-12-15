{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { nixpkgs, home-manager, nixpkgs-unstable, impermanence, ... }@inputs:
  let
    module-list = import ./modules;

    mkSystem = { system, name }:
      let
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

        overlays = [
          inputs.zig.overlays.default
          (import ./overlays/pkgs.nix)
          (import ./overlays/unstable.nix {
            inherit pkgs-unstable;
          })
        ];
      in nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          # Custom modules
          { imports = module-list.system; }

          # Overlays
          { nixpkgs.overlays = overlays; }

          home-manager.nixosModule
          impermanence.nixosModules.impermanence
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
            home-manager.users.clement = {
              imports = module-list.home ++ [ ./hosts/${name}/home.nix ];
            };
          }
        ];
      };

    hosts = {
      engardo = {
        system = "aarch64-linux";
      };

      syra = {
        system = "x86_64-linux";
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: value: mkSystem (value // { inherit name; })) hosts;
  };
}
