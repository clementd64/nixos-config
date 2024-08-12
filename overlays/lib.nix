prev: final:
{
  buildCiliumChart = final.callPackage ../lib/buildCiliumChart.nix;
  fetchStaticBinary = final.callPackage ../lib/fetchStaticBinary.nix;
  k8s = final.callPackage ../lib/k8s.nix {};
  kube-vip = final.callPackage ../lib/kube-vip.nix {};
}
