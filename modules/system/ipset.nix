{ config, lib, pkgs, ... }:

with lib; {
  options.networking.ipset = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        type = mkOption {
          type = types.str;
        };

        family = mkOption {
          type = types.enum [ "ipv4" "ipv6" ];
          default = "ipv4";
        };

        set = mkOption {
          type = types.listOf types.str;
          default = [];
        };

        extraArgs = mkOption {
          type = types.str;
          default = "";
        };
      };
    });
    default = {};
  };

  config = mkIf ((builtins.length (attrsToList config.networking.ipset)) > 0) {
    assertions = [
      {
        assertion = config.networking.firewall.enable == true;
        message = "firewall must be enabled to use ipset";
      }
      {
        assertion = config.networking.nftables.enable == false;
        message = "ipset is not compatible with nftables";
      }
    ];

    networking.firewall = let
      mkSet = name: cfg:
        let
          setName = "nixos-${name}";
        in ''
          ipset create ${setName} ${cfg.type} family ${{ "ipv4" = "inet"; "ipv6" = "inet6"; }.${cfg.family}} ${cfg.extraArgs}
          ${concatMapStringsSep "\n" (value: "ipset add ${setName} ${value}") cfg.set}
        '';
    in {
      extraPackages = [ pkgs.ipset ];
      extraCommands = mkBefore ''
        ipset list -name | { grep ^nixos- || true; } | xargs --no-run-if-empty -L1 ipset destroy
        ${concatStringsSep "\n" (mapAttrsToList mkSet config.networking.ipset)}
      '';
    };
  };
}
