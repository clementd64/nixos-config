{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.mesh;
  pairName = a: b: concatStringsSep "-" (sort builtins.lessThan [ a b ]);
  presharedKeySecret = peerName:
    "wg-mesh-preshared-key-${pairName config.networking.hostName peerName}";

  peer = types.submodule ({ name, ... }: {
    options = {
      publicKey = mkOption {
        type = types.str;
        description = "WireGuard public key for this mesh peer";
      };

      presharedKey = mkOption {
        type = types.str;
        description = "SOPS selector for this mesh peer's WireGuard preshared key";
      };

      endpoint = mkOption {
        type = types.str;
        default = "${name}.h.as212625.net:${toString cfg.listenPort}";
        description = "WireGuard endpoint for this mesh peer";
      };
    };
  });
in {
  options.clement.mesh = {
    enable = mkEnableOption "WireGuard mesh";

    listenPort = mkOption {
      type = types.port;
      default = 51824;
      description = "UDP port used by the WireGuard mesh";
    };

    mtu = mkOption {
      type = types.int;
      default = 1420;
      description = "MTU of the WireGuard mesh interface";
    };

    vrf = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "VRF interface to attach the WireGuard mesh interface to";
    };

    secretsFile = mkOption {
      type = types.path;
      description = "SOPS file containing the WireGuard mesh keys";
    };

    privateKey = mkOption {
      type = types.str;
      description = "SOPS selector for the local WireGuard private key";
    };

    peers = mkOption {
      type = types.attrsOf peer;
      default = {};
      description = "Named WireGuard mesh peers";
    };
  };

  config = mkIf cfg.enable {
    clement.secrets = {
      "wg-mesh-private-key" = {
        file = cfg.secretsFile;
        extract = cfg.privateKey;
        user = "systemd-network";
        before = [ "systemd-networkd.service" ];
      };
    } // mapAttrs' (peerName: value:
      nameValuePair (presharedKeySecret peerName) {
        file = cfg.secretsFile;
        extract = value.presharedKey;
        user = "systemd-network";
        before = [ "systemd-networkd.service" ];
      }
    ) cfg.peers;

    systemd.network = {
      netdevs."20-wg-mesh" = {
        netdevConfig = {
          Name = "wg-mesh";
          Kind = "wireguard";
          MTUBytes = cfg.mtu;
        };
        wireguardConfig = {
          PrivateKeyFile = config.clement.secrets."wg-mesh-private-key".path;
          ListenPort = cfg.listenPort;
        };
        wireguardPeers = attrsets.mapAttrsToList (name: value: {
          PublicKey = value.publicKey;
          PresharedKeyFile = config.clement.secrets."${presharedKeySecret name}".path;
          AllowedIPs = [ "${pkgs.net.genLinkLocal name}/128" ];
          Endpoint = value.endpoint;
        }) cfg.peers;
      };

      networks."20-wg-mesh" = {
        matchConfig.Name = "wg-mesh";
        networkConfig = {
          Address = [ "${pkgs.net.genLinkLocal config.networking.hostName}/64" ];
          VRF = mkIf (cfg.vrf != null) cfg.vrf;
        };
      };
    };

    networking.firewall.allowedUDPPorts = [ cfg.listenPort ];
    environment.systemPackages = [ pkgs.wireguard-tools ];
  };
}
