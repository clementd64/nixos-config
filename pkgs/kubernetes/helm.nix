{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "helm";
  version = "3.12.3";
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "1b2313cd198d45eab00cc37c38f6b1ca0a948ba279c29e322bdf426d406129b5";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "79ef06935fb47e432c0c91bdefd140e5b543ec46376007ca14a52e5ed3023088";
      path = "linux-arm64/helm";
    };
  };
}