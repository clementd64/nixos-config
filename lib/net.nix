{ lib }:
rec {
  bogonIPv4 = [
    "0.0.0.0/8"
    "10.0.0.0/8" # Private Use
    "100.64.0.0/10" # Shared Address Space
    "169.254.0.0/16" # Link Local
    "127.0.0.0/8" # Loopback
    "172.16.0.0/12" # Private Use
    "185.1.0.0/16" # RIPE IXP Assignment
    "192.0.0.0/24" # IETF Protocol Assignments
    "192.0.2.0/24" # TEST-NET-1
    "192.168.0.0/16" # Private Use
    "198.18.0.0/15" # Benchmarking
    "198.51.100.0/24" # TEST-NET-2
    "203.0.113.0/24" # TEST-NET-3
    "224.0.0.0/4" # Multicast
    "240.0.0.0/4" # Reserved
  ];

  bogonIPv6 = [
    "::/128"
    "::1/128" # Loopback
    "::ffff:0:0/96" # IPv4-mapped
    "64:ff9b:1::/48" # IPv4-IPv6 Translation
    "2001::/23" # IETF Protocol Assignments
    "2001:2::/48" # Benchmarking
    "2001:db8::/32" # Documentation
    "3fff::/20" # Documentation
    "5f00::/16" # Segment Routing
    "fc00::/7" # Unique-Local
    "fe80::/10" # Link Local
    "ff00::/8" # Multicast
  ];

  # Test if a string look like an IPv4 address.
  # Only the format is checked, not the validity of the address. (e.g. 999.999.999.999 is considered valid)
  # Only dot-decimal notation is supported.
  # Also match CIDR notation (no prefix length check)
  isIPv4 = ip: builtins.match ''^[0-9]+(\.[0-9]+){1,3}(/[0-9]+)?$'' ip != null;

  # Filter a list of strings to keep only the ones that look like an IPv4 address.
  filterIPv4 = list: builtins.filter isIPv4 list;

  # Filter a list of strings to keep only the ones that do not look like an IPv4 address.
  # Only keep IPv6 assuming the list contains only valid IPs.
  filterIPv6 = list: builtins.filter (ip: !isIPv4 ip) list;

  # Generate an IPv6 link-local address derived from a hostname.
  genIPv6Addr = prefix: hostname: let
    interfaceId = builtins.substring 0 16 (builtins.hashString "sha256" hostname);
    hextets = builtins.genList (index: builtins.substring (index * 4) 4 interfaceId) 4;
  in
    "${prefix}${builtins.concatStringsSep ":" hextets}";

  genLinkLocal = genIPv6Addr "fe80::";

  ipsetRule =
    {
      name,
      type,
      family,
      set,
      rules,
    }: let
      ipset = "nixos-${name}";
      iptables = {
        ipv4 = "iptables";
        ipv6 = "ip6tables";
      }.${family};
      enabled = builtins.length set > 0;
    in {
      ipset = lib.optionalAttrs enabled {
        "${name}" = {
          inherit type family set;
        };
      };

      extraCommands = lib.optionalString enabled (rules {
        inherit iptables ipset;
      });
    };

  ipsetRules =
    {
      name,
      type,
      set,
      rules,
      filters ? {
        ipv4 = filterIPv4;
        ipv6 = filterIPv6;
      },
    }: let
      ipv4 = ipsetRule {
        inherit type rules;
        name = "${name}-ipv4";
        family = "ipv4";
        set = filters.ipv4 set;
      };
      ipv6 = ipsetRule {
        inherit type rules;
        name = "${name}-ipv6";
        family = "ipv6";
        set = filters.ipv6 set;
      };
    in {
      ipset = ipv4.ipset // ipv6.ipset;
      extraCommands = ipv4.extraCommands + ipv6.extraCommands;
    };
}
