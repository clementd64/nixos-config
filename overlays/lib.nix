prev: final:
{
  fetchOCIRootfs = final.callPackage ../lib/fetchOCIRootfs.nix;
  fetchStaticBinary = final.callPackage ../lib/fetchStaticBinary.nix;
  net = prev.callPackage ../lib/net.nix { inherit (prev) lib; };
}
