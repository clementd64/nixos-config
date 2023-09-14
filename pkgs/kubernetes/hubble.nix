{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "hubble";
  version = "0.12.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-amd64.tar.gz";
      sha256 = "286ed8fecdcb552de9bc65aa828fa03722470d4b60af99602f401615bd489719";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-arm64.tar.gz";
      sha256 = "62d73a73f7baa0e13d1a62a8a2d7475858307e0d762dde55f2c51220e2ae8a61";
    };
  };
}