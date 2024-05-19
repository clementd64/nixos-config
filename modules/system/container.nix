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

      persistDir = mkOption {
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
          IPForward = true;
        };
        routes = [
          # TODO: set configurable
          { routeConfig = { Destination = "2a01:4f8:c17:aad:1::/80"; Gateway = "2a01:4f8:c17:aad:ff00::1"; };}
          { routeConfig = { Destination = "2a01:4f8:c17:aad:2::/80"; Gateway = "2a01:4f8:c17:aad:ff00::2"; };}
          { routeConfig = { Destination = "2a01:4f8:c17:aad:3::/80"; Gateway = "2a01:4f8:c17:aad:ff00::3"; };}
        ];
        linkConfig = {
          RequiredForOnline = "no";
        };
      };
    };

    networking.firewall.extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.0.0.0/24 ! -o br-ctr -j MASQUERADE
    '';

    environment.etc = attrsets.mapAttrs' (name: value: {
      name = "nixos-containers/${name}.conf";
      value = {
        text = strings.concatStringsSep "\n" (
          [
            "PRIVATE_NETWORK=1"
            "HOST_BRIDGE=br-ctr"
          ]
          ++ optional value.persistDir "EXTRA_NSPAWN_FLAGS=--bind=/nix/persist/nixos-containers/${name}:/nix/persist"
        );
      };
    }) cfg.containers;

    systemd.nspawn = builtins.mapAttrs (name: value: {
      # Allow running OCI containers
      execConfig.SystemCallFilter = [ "add_key" "keyctl" "bpf" ];
    }) cfg.containers;

    # Start on boot
    systemd.targets.machines.wants = attrsets.mapAttrsToList (n: v: "container@${n}.service")
        (filterAttrs (n: v: v.autostart) cfg.containers);

    # Create required directories
    systemd.tmpfiles.rules = lists.flatten (attrsets.mapAttrsToList (name: value:
      ["d /nix/var/nix/profiles/per-container/${name} - root root - -"]
      ++ optional value.persistDir "d /nix/persist/nixos-containers/${name} - root root - -"
    ) cfg.containers);
  };
}