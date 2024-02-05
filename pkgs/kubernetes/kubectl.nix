{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.29.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "69ab3a931e826bf7ac14d38ba7ca637d66a6fcb1ca0e3333a2cafdf15482af9f";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "96d6dc7b2bdcd344ce58d17631c452225de5bbf59b83fd3c89c33c6298fb5d8b";
    };
  };
}