{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "kind";
  version = "0.24.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-amd64";
      sha256 = "b89aada5a39d620da3fcd16435b7f28d858927dd53f92cbac77686b0588b600d";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-arm64";
      sha256 = "2968808d916e12d0a25c56d07c9a1c987163f972513fa8a94a2125a69f9c50eb";
    };
  };
}