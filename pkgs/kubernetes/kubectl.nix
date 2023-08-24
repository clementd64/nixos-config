{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.28.0";
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "4717660fd1466ec72d59000bb1d9f5cdc91fac31d491043ca62b34398e0799ce";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "f5484bd9cac66b183c653abed30226b561f537d15346c605cc81d98095f1717c";
    };
  };
}