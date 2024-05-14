{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "helm";
  version = "3.14.4";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "a5844ef2c38ef6ddf3b5a8f7d91e7e0e8ebc39a38bb3fc8013d629c1ef29c259";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "113ccc53b7c57c2aba0cd0aa560b5500841b18b5210d78641acfddc53dac8ab2";
      path = "linux-arm64/helm";
    };
  };
}