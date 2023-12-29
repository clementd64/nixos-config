{
  description = "NixOS configuration for clementd64";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-stable.url = github:NixOS/nixpkgs/nixos-23.11;
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    impermanence.url = "github:nix-community/impermanence";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { ... }@inputs:
  let
    module-list = import ./modules;

    mkSystem = { system, name, nixpkgs, home-manager, modules ? [], overlays ? [] }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          {
            # Custom modules
            imports = module-list.system;

            # Overlays
            nixpkgs.overlays = [
              inputs.zig.overlays.default
              (import ./overlays/pkgs.nix)
            ] ++ overlays;
          }

          home-manager.nixosModule
          inputs.impermanence.nixosModules.impermanence
          ./hosts/${name}/system.nix
          {
            nix = {
              settings = {
                auto-optimise-store = true;
                experimental-features = [ "nix-command" "flakes" ];
              };

              registry.nixpkgs.flake = nixpkgs;
            };
            nixpkgs.config.allowUnfree = true;

            networking.hostName = name;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.clement = {
              imports = module-list.home ++ [ ./hosts/${name}/home.nix ];
            };
          }
        ] ++ modules;
      };

    mkStable = { system }: {
      inherit system;
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
      overlays = [
        (import ./overlays/unstable.nix {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    };

    mkUnstable = { system }: {
      inherit system;
      nixpkgs = inputs.nixpkgs-unstable;
      home-manager = inputs.home-manager-unstable;
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

      syra = mkUnstable {
        system = "x86_64-linux";
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: value: mkSystem (value // { inherit name; })) hosts;

    diskoConfigurations = builtins.mapAttrs (name: value: import ./hosts/${name}/disk.nix)
      (inputs.nixpkgs-stable.lib.filterAttrs (name: value: builtins.pathExists ./hosts/${name}/disk.nix) hosts);
  };
}
