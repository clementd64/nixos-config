{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.28.4";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "893c92053adea6edbbd4e959c871f5c21edce416988f968bec565d115383f7b8";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "edf1e17b41891ec15d59dd3cc62bcd2cdce4b0fd9c2ee058b0967b17534457d7";
    };
  };
}