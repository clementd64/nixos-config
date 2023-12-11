{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "helm";
  version = "3.13.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "55a8e6dce87a1e52c61e0ce7a89bf85b38725ba3e8deb51d4a08ade8a2c70b2d";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "f5654aaed63a0da72852776e1d3f851b2ea9529cb5696337202703c2e1ed2321";
      path = "linux-arm64/helm";
    };
  };
}