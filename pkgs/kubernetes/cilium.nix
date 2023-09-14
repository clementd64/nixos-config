{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  pname = "cilium-cli-bin";
  name = "cilium";
  version = "0.15.8";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-amd64.tar.gz";
      sha256 = "e546ef1eb5df5f7342d92c1ac9c21dbf7bce56004858db4091f0b62df1725ac3";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-arm64.tar.gz";
      sha256 = "a879a5c5cf3e2e6cd9dbf380a67bb50652b86ed0c5a0366305ff34c16e3be47c";
    };
  };
}