{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kind";
  version = "0.20.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-amd64";
      sha256 = "513a7213d6d3332dd9ef27c24dab35e5ef10a04fa27274fe1c14d8a246493ded";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-arm64";
      sha256 = "639f7808443559aa30c3642d9913b1615d611a071e34f122340afeda97b8f422";
    };
  };
}