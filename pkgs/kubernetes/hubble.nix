{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "hubble";
  version = "0.12.3";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-amd64.tar.gz";
      sha256 = "f87b0ce1b0264d9a6218609e7df20003e0667d3183ae6d4a77a702bb14f19b63";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-arm64.tar.gz";
      sha256 = "2d1491cdaf594f0bd0d45d70d815c2526e379d47e40274650474dbd27c192e06";
    };
  };
}