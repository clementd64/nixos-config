{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-stable.url = github:nixos/nixpkgs/nixos-24.05;
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    impermanence.url = "github:nix-community/impermanence";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { ... }@inputs:
  let
    module-list = import ./modules;

    mkSystem = { system, name, nixpkgs, home-manager, enable-home-manager ? false, modules ? [], overlays ? [] }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          inputs.impermanence.nixosModules.impermanence
          {
            # Custom modules
            imports = module-list.system;

            # Overlays
            nixpkgs.overlays = [
              inputs.zig.overlays.default
              (import ./overlays/pkgs.nix)
            ] ++ overlays;

            nix = {
              settings = {
                auto-optimise-store = true;
                experimental-features = [ "nix-command" "flakes" ];
              };

              registry.nixpkgs.flake = nixpkgs;
            };
            nixpkgs.config.allowUnfree = true;

            networking.hostName = name;
          }
        ] ++ modules
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}/system.nix) ./hosts/${name}/system.nix
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}.nix) ./hosts/${name}.nix
          ++ nixpkgs.lib.optionals enable-home-manager [
            home-manager.nixosModule
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.clement = with nixpkgs.lib; {
                imports = module-list.home
                  ++ optional (builtins.pathExists ./hosts/${name}/home.nix) ./hosts/${name}/home.nix;

                clement = {
                  fish.enable = mkDefault true;
                  htop.enable = mkDefault true;
                  starship.enable = mkDefault true;
                };

                home.stateVersion = mkDefault "23.11";
              };
            }
          ];
      };

    mkStable = { system, home ? false }: {
      inherit system;
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
      enable-home-manager = home;
      overlays = [
        (import ./overlays/unstable.nix {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    };

    mkUnstable = { system, home ? false }: {
      inherit system;
      nixpkgs = inputs.nixpkgs-unstable;
      home-manager = inputs.home-manager-unstable;
      enable-home-manager = home;
      modules = [
        { clement.unstable.enable = true; }
      ];
    };

    hosts = {
      engardo = mkStable {
        system = "aarch64-linux";
      };

      flamii = mkStable {
        system = "x86_64-linux";
      };

      seebu = mkStable {
        system = "aarch64-linux";
      };

      syra = mkUnstable {
        system = "x86_64-linux";
        home = true;
      };

      aeacus = mkStable {
        system = "aarch64-linux";
      };

      minos = mkStable {
        system = "aarch64-linux";
      };

      rhadamanthus = mkStable {
        system = "aarch64-linux";
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: value: mkSystem (value // { inherit name; })) hosts;

    diskoConfigurations = builtins.mapAttrs (name: value: import ./hosts/${name}/disk.nix)
      (inputs.nixpkgs-stable.lib.filterAttrs (name: value: builtins.pathExists ./hosts/${name}/disk.nix) hosts);

    packages = builtins.listToAttrs (builtins.map (system: {
      name = system;
      value = inputs.nixpkgs-unstable.legacyPackages.${system}.callPackage (import ./pkgs) {};
    }) ["x86_64-linux" "aarch64-linux"]);
  };
}
