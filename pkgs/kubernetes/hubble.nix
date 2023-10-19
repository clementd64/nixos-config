{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "hubble";
  version = "0.12.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-amd64.tar.gz";
      sha256 = "e0162f4c096a6435cf1e60712448bbaf91d10440b5da1fbb7bd9e711dacd3016";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-arm64.tar.gz";
      sha256 = "921a23ade725e14c493cf1e9aeefdf185edaf57e487274fec848149375597e2c";
    };
  };
}