{ callPackage }:
callPackage ../../lib/fetchStaticBinary.nix rec {
  name = "flux";
  pname = "fluxcd-bin";
  version = "2.3.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_amd64.tar.gz";
      sha256 = "51ef10a0ebf2078e52476c4d168200a1db73feef987e0bc8722f4ce4fcd4b6d9";
    };
    aarch64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_arm64.tar.gz";
      sha256 = "29d2363cfdf13546d900986d265f336ed18c6bbb12d0530c624eaa2ff27b547e";
    };
  };
}