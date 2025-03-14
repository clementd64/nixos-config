{ config, lib, pkgs, ... }:

with lib;
{
  options.clement.mesh = {
    secretsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    address = mkOption {
      type = types.str;
    };

    port = mkOption {
      type = types.nullOr types.int;
      default = null;
    };

    peers = mkOption {
      type = types.attrs;
      default = {
        auresco = {
          PublicKey = "PZlLUirj+gk24ZEkNAUJZdcN8sPxPsXEaZisXIJ07Gw=";
          AllowedIPs = ["fd34:ad42:6ef8::2/128"];
          Endpoint = "[2a01:4f8:c012:79f8::1]:57205";
        };
        seebu = {
          PublicKey = "jJvJIRLPAkKkddMPN+dNPtvMk1bo2sN/BmIHmPfOPCE=";
          AllowedIPs = ["fd34:ad42:6ef8::1/128"];
          Endpoint = "[2a01:4f8:c013:578a::1]:57205";
        };
      };
      internal = true;
      readOnly = true;
    };
  };

  config = mkIf (config.clement.mesh.secretsFile != null) {
    clement.secrets."mesh-private-key" = {
      file = config.clement.mesh.secretsFile;
      extract = ''["mesh"]["private-key"]'';
      user = "systemd-network";
      before = [ "systemd-networkd.service" ];
    };

    systemd.network = {
      netdevs."20-mesh" = {
        netdevConfig = {
          Name = "mesh";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = config.clement.secrets."mesh-private-key".path;
          ListenPort = mkIf (config.clement.mesh.port != null) config.clement.mesh.port;
        };
        wireguardPeers = attrsets.attrValues (filterAttrs (n: v: n != config.networking.hostName) config.clement.mesh.peers);
      };

      networks."20-mesh" = {
        matchConfig.Name = "mesh";
        networkConfig = {
          Address = [ "${config.clement.mesh.address}/64" ];
        };
      };
    };

    networking.firewall.allowedUDPPorts = mkIf (config.clement.mesh.port != null) [ config.clement.mesh.port ];

    environment.systemPackages =  [ pkgs.wireguard-tools ];
  };
}
