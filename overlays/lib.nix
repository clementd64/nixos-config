prev: final:
{
  fetchOCIRootfs = final.callPackage ../lib/fetchOCIRootfs.nix;
  fetchStaticBinary = final.callPackage ../lib/fetchStaticBinary.nix;
  net = final.callPackage ../lib/net.nix {};
}
