{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "kind";
  version = "0.23.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-amd64";
      sha256 = "1d86e3069ffbe3da9f1a918618aecbc778e00c75f838882d0dfa2d363bc4a68c";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-arm64";
      sha256 = "a416d6c311882337f0e56910e4a2e1f8c106ec70c22cbf0ac1dd8f33c1e284fe";
    };
  };
}