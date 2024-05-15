{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.30.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "5b86f0b06e1a5ba6f8f00e2b01e8ed39407729c4990aeda961f83a586f975e8a";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "d90446719b815e3abfe7b2c46ddf8b3fda17599f03ab370d6e47b1580c0e869e";
    };
  };
}