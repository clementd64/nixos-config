{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  pname = "cilium-cli-bin";
  name = "cilium";
  version = "0.15.7";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-amd64.tar.gz";
      sha256 = "de3837e4730c02e20dcdb24b3bede2f7668b4e9989540e57fe6e061f556e2d65";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-arm64.tar.gz";
      sha256 = "2cbedca34370ee26a3e4aa96f2171b100a1d63246925a130987891cbbc4a753d";
    };
  };
}