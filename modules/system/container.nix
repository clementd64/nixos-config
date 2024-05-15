{ config, lib, pkgs, ... }:

# (almost) declaratively manage imperative nixos-containers
# Need to be bootstrapped (to add profile to nix store) with
#   sudo nixos-container update hostname --flake github:clementd64/nixos-config#hostname
# rootfs in /var/lib/nixos-containers is generated when started, so tmpfs as root setup is possible

with lib; let
  cfg = config.clement.container;

  containerOptions = {
    options = {
      autostart = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
in {
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

    environment.etc = attrsets.mapAttrs' (name: value: {
      name = "nixos-containers/${name}.conf";
      value = {
        text = ''
          PRIVATE_NETWORK=1
          HOST_BRIDGE=br-ctr
        '';
      };
    }) cfg.containers;

    systemd.nspawn = builtins.mapAttrs (name: value: {
      # Allow running containers
      execConfig.SystemCallFilter = [ "add_key" "keyctl" "bpf" ];
    }) cfg.containers;

    # Start on boot
    systemd.targets.machines.wants = attrsets.mapAttrsToList (n: v: "container@${n}.service")
        (filterAttrs (n: v: v.autostart) cfg.containers);
  };
}