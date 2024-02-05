{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "helm";
  version = "3.14.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "f43e1c3387de24547506ab05d24e5309c0ce0b228c23bd8aa64e9ec4b8206651";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "b29e61674731b15f6ad3d1a3118a99d3cc2ab25a911aad1b8ac8c72d5a9d2952";
      path = "linux-arm64/helm";
    };
  };
}