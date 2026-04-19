{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.clement.firewall;

  ipsetAddress = value: builtins.head (builtins.split "," value);

  mkRule = dir: pkgs.net.ipsetRules {
    name = "firewall-${dir}";
    type = "hash:net,port";
    set = concatMap (key: map (ip: "${ip},${key}") cfg.${dir}.${key}) (attrNames cfg.${dir});
    filters = {
      ipv4 = set: builtins.filter (value: pkgs.net.isIPv4 (ipsetAddress value)) set;
      ipv6 = set: builtins.filter (value: !pkgs.net.isIPv4 (ipsetAddress value)) set;
    };
    rules = { iptables, ipset }: ''
      ${iptables} -A nixos-fw -m set --match-set ${ipset} ${dir},dst -j ACCEPT
    '';
  };

  srcRule = mkRule "src";
  dstRule = mkRule "dst";
in {
  options.clement.firewall = {
    src = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
    };

    dst = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
    };
  };

  config = mkIf (cfg.src != {} || cfg.dst != {}) {
    networking.ipset = srcRule.ipset // dstRule.ipset;
    networking.firewall.extraCommands = srcRule.extraCommands + dstRule.extraCommands;
  };
}
