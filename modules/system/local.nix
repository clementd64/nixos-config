{ config, lib, ... }:

with lib; {
  options.clement.local = {
    addresses = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    routes = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config.systemd.network.networks."20-lo" = mkIf (builtins.length config.clement.local.addresses > 0 || builtins.length config.clement.local.routes > 0) {
    matchConfig.Name = "lo";
    networkConfig = {
      Address = config.clement.local.addresses;
    };
    routes = map (route: { Type = "local"; Destination = route; }) config.clement.local.routes;
  };
}
