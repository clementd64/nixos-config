{ config, lib, pkgs, utils, ... }:

with lib; let
  wireguard = types.submodule ({ ... }: {
    options = {
      secretsFile = mkOption {
        type = types.path;
      };

      privateKey = mkOption {
        type = types.str;
      };

      presharedKey = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      publicKey = mkOption {
        type = types.str;
      };

      port = mkOption {
        type = types.nullOr types.int;
        default = null;
      };

      addresses = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      endpoint = mkOption {
        type = types.str;
        default = null;
      };

      allowedIps = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      dns = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      domains = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  });
in {
  options.clement.wireguard = mkOption {
    type = types.attrsOf wireguard;
    default = {};
  };

  config.clement.secrets = mkMerge (attrsets.mapAttrsToList (name: value: {
    "wg-${name}-private-key" = {
      file = value.secretsFile;
      extract = value.privateKey;
      user = "systemd-network";
      before = [ "systemd-networkd.service" ];
    };

    "wg-${name}-preshared-key" = mkIf (value.presharedKey != null) {
      file = value.secretsFile;
      extract = value.presharedKey;
      user = "systemd-network";
      before = [ "systemd-networkd.service" ];
    };
  }) config.clement.wireguard);

  config.systemd.network = mkMerge (attrsets.mapAttrsToList (name: value: {
    netdevs."20-${name}" = {
      netdevConfig = {
        Name = "wg-${name}";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.clement.secrets."wg-${name}-private-key".path;
        ListenPort = mkIf (value.port != null) value.port;
      };
      wireguardPeers = [{
        PublicKey = value.publicKey;
        PresharedKeyFile = mkIf (value.presharedKey != null) config.clement.secrets."wg-${name}-preshared-key".path;
        AllowedIPs = mkIf (value.allowedIps != null) value.allowedIps;
        Endpoint = mkIf (value.endpoint != null) value.endpoint;
      }];
    };

    networks."20-${name}" = {
      matchConfig.Name = "wg-${name}";
      networkConfig = {
        Address = value.addresses;
        DNS = value.dns;
        Domains = value.domains;
      };
      routes = mkIf (value.allowedIps != null) [
        {
          Destination = value.allowedIps;
          Scope = "link";
        }
      ];
    };
  }) config.clement.wireguard);

  config.networking.firewall.allowedUDPPorts = attrsets.mapAttrsToList
    (name: value: value.port)
    (filterAttrs (name: value: value.port != null) config.clement.wireguard);
}
