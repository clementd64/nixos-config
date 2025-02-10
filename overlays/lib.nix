prev: final:
{
  fetchStaticBinary = final.callPackage ../lib/fetchStaticBinary.nix;
  net = final.callPackage ../lib/net.nix {};
}
