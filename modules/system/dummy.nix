{ config, lib, ... }:

with lib; let
  dummyInterface = types.submodule ({ name, ... }: {
    options = {
      interface = mkOption {
        type = types.str;
        default = name;
      };

      addresses = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  });
in {
  options.clement.dummy = mkOption {
    type = types.attrsOf dummyInterface;
    default = {};
  };

  config.systemd.network = mkMerge (attrsets.mapAttrsToList (_: value: {
    netdevs."20-${value.interface}" = {
      netdevConfig = {
        Name = value.interface;
        Kind = "dummy";
      };
    };

    networks."20-${value.interface}" = {
      matchConfig.Name = value.interface;
      networkConfig = {
        Address = value.addresses;
      };
    };
  }) config.clement.dummy);
}
