{}: rec {
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
}
