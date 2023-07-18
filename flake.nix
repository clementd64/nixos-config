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
        ];
      };
  in {
    nixosConfigurations.alfeto = mkSystem {
      name = "alfeto";
      system = "x86_64-linux";
    };

    nixosConfigurations.syra = mkSystem {
      name = "syra";
      system = "x86_64-linux";
    };
  };
}
