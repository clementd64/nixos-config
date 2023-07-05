{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/23.05;
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, ... }@inputs:
  let
    currentSystem = "x86_64-linux";
    # Get unstable nixpkgs with allowUnfree for vscode
    pkgs-unstable = import nixpkgs-unstable {
      system = currentSystem;
      config.allowUnfree = true;
    };
  in {
    # TODO: factorize
    nixosConfigurations.alfeto = nixpkgs.lib.nixosSystem {
      system = currentSystem;

      modules = [
        home-manager.nixosModule
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.clement =  import ./users/clement;
        }
        ./hardware/alfeto.nix
        ./hosts/alfeto
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            (final: prev: {
              vscode =  pkgs-unstable.vscode;
            })
          ];
        }
      ];
    };
  };
}