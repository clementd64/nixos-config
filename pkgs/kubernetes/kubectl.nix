{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.30.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "7c3807c0f5c1b30110a2ff1e55da1d112a6d0096201f1beb81b269f582b5d1c5";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "669af0cf520757298ea60a8b6eb6b719ba443a9c7d35f36d3fb2fd7513e8c7d2";
    };
  };
}