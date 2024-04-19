{ config, lib, pkgs, ... }:

let
  cfg = config.clement.container;

  containerOptions = {
    options = {};
  };
in with lib; {
  options.clement.container = {
    enable = mkEnableOption "Enable container";

    addresses = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    containers = mkOption {
      type = types.attrsOf (types.submodule containerOptions);
    };
  };

  config = mkIf cfg.enable {
    systemd.network = {
      netdevs."20-br-ctr" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-ctr";
        };
      };

      networks."20-br-ctr" = {
        matchConfig.Name = "br-ctr";
        networkConfig = {
          Address = cfg.addresses;
          IPMasquerade = "ipv4";
          IPForward = true;
        };
        routes = [
          # TODO: set configurable
          { routeConfig = { Destination = "2a01:4f8:c17:aad:1::1/80"; Gateway = "2a01:4f8:c17:aad:ff00::1"; };}
        ];
        linkConfig = {
          RequiredForOnline = "no";
        };
      };
    };

    systemd.nspawn = builtins.mapAttrs (name: value: {
      # Allow running containers
      execConfig.SystemCallFilter = [ "add_key" "keyctl" "bpf" ];
    }) cfg.containers;
  };
}