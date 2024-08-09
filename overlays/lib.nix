prev: final:
{
  buildCiliumChart = final.callPackage ../lib/buildCiliumChart.nix;
  fetchStaticBinary = final.callPackage ../lib/fetchStaticBinary.nix;
}
