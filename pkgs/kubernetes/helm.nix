{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "helm";
  version = "3.13.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "98c363564d00afd0cc3088e8f830f2a0eeb5f28755b3d8c48df89866374a1ed0";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "8c4a0777218b266a7b977394aaf0e9cef30ed2df6e742d683e523d75508d6efe";
      path = "linux-arm64/helm";
    };
  };
}