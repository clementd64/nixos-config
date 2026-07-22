{ config, lib, ... }:

with lib; let
  cfg = config.clement.profile.mesh;
  nodes = {
    ekidno.publicKey = "0cdkA+Jor6jujHzBcq3+5iPZV3YxkoLL3cg8UWFEzzU=";
    erythia.publicKey = "mJt+/muouypEGO9oByjQKx89hsyC/FGB5CMPQblexG8=";
    flamii.publicKey = "P6k7ZVkcpMEpxJR/mkF9vK7KFqMeoKQMpomFzdk3Wg0=";
  };
  pairName = a: b: concatStringsSep "-" (sort builtins.lessThan [ a b ]);
in {
  options.clement.profile.mesh.enable = mkEnableOption "WireGuard mesh profile";

  config = mkIf cfg.enable {
    assertions = [{
      assertion = builtins.hasAttr config.networking.hostName nodes;
      message = "clement.profile.mesh: networking.hostName '${config.networking.hostName}' is not present in the mesh node registry";
    }];

    clement.mesh = {
      enable = true;
      secretsFile = ./secrets.json;
      privateKey = ''["private-keys"]["${config.networking.hostName}"]'';
      peers = mapAttrs (peerName: peerNode: {
        inherit (peerNode) publicKey;
        presharedKey = ''["preshared-keys"]["${pairName config.networking.hostName peerName}"]'';
      }) (removeAttrs nodes [ config.networking.hostName ]);
    };
  };
}
