{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-stable.url = github:nixos/nixpkgs/nixos-25.05;
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    zig.url = "github:mitchellh/zig-overlay";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = { ... }@inputs:
  let
    module-list = import ./modules;

    baseOverlays = [
      inputs.zig.overlays.default
      inputs.ghostty.overlays.default
      (import ./overlays/pkgs.nix)
      (import ./overlays/lib.nix)
    ];

    mkSystem =
      # 1. Factory for mkStable and mkUnstable
      { nixpkgs, home-manager }:
      # 2. Hosts configuration
      { system, modules ? [] }:
      # 3. Auto hostname injection (avoid duplication)
      name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            networking.hostName = name;
            nixpkgs.overlays = baseOverlays;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
          inputs.impermanence.nixosModules.impermanence
        ] ++ module-list.system
          ++ modules
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}/system.nix) ./hosts/${name}/system.nix
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}/hardware.nix) ./hosts/${name}/hardware.nix
          ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}.nix) ./hosts/${name}.nix
          ++ nixpkgs.lib.optionals (builtins.pathExists ./hosts/${name}/home.nix) [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.clement = with nixpkgs.lib; {
                imports = [./hosts/${name}/home.nix]
                  ++ module-list.home;

                clement = {
                  fish.enable = mkDefault true;
                  htop.enable = mkDefault true;
                  starship.enable = mkDefault true;
                };
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
      cadensia = mkStable {
        system = "x86_64-linux";
      };

      ekidno = mkStable {
        system = "x86_64-linux";
      };

      flamii = mkStable {
        system = "x86_64-linux";
      };

      syra = mkUnstable {
        system = "x86_64-linux";
        modules = [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };

      tarzan = mkStable {
        system = "x86_64-linux";
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
