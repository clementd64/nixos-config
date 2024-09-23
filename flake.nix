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

    baseOverlays = [
      inputs.zig.overlays.default
      (import ./overlays/pkgs.nix)
      (import ./overlays/lib.nix)
    ];

    mkSystem =
      # 1. Factory for mkStable and mkUnstable
      { nixpkgs, home-manager, modules ? [], overlays ? [] }:
      # 2. Hosts configuration
      { system, home ? false }:
      # 3. Auto hostname injection (avoid duplication)
      name: nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          {
            networking.hostName = name;
            nixpkgs.overlays = baseOverlays ++ overlays;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
          inputs.impermanence.nixosModules.impermanence
        ] ++ module-list.system
          ++ modules
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}/system.nix) ./hosts/${name}/system.nix
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}.nix) ./hosts/${name}.nix
          ++ nixpkgs.lib.optionals home [
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

    mkStable = mkSystem {
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
    };

    mkUnstable = mkSystem {
      nixpkgs = inputs.nixpkgs-unstable;
      home-manager = inputs.home-manager-unstable;
    };

    hosts = {
      ekidno = mkStable {
        system = "aarch64-linux";
      };

      flamii = mkStable {
        system = "x86_64-linux";
      };

      seebu = mkStable {
        system = "aarch64-linux";
      };

      olethro = mkStable {
        system = "aarch64-linux";
      };

      syra = mkUnstable {
        system = "x86_64-linux";
        home = true;
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: mkSystem: mkSystem name) hosts;

    diskoConfigurations = builtins.mapAttrs (name: value: import ./hosts/${name}/disk.nix)
      (inputs.nixpkgs-stable.lib.filterAttrs (name: value: builtins.pathExists ./hosts/${name}/disk.nix) hosts);

    packages = builtins.listToAttrs (builtins.map (system:
      let
        pkgs = import inputs.nixpkgs-unstable { inherit system; overlays = baseOverlays; };
      in {
        name = system;
        value = (import ./pkgs) { inherit (pkgs) callPackage; };
      }
    ) ["x86_64-linux" "aarch64-linux"]);
  };
}
