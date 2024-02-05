{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kind";
  version = "0.21.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-amd64";
      sha256 = "7bf22d258142eaa0e53899ded3ad06bae1b3e8ae5425a5e4dc5c8f9f263094a7";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes-sigs/kind/releases/download/v${version}/kind-linux-arm64";
      sha256 = "d56d98fe8a22b5a9a12e35d5ff7be254ae419b0cfe93b6241d0d14ece8f5adc8";
    };
  };
}