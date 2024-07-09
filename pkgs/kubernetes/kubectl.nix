{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.30.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "c6e9c45ce3f82c90663e3c30db3b27c167e8b19d83ed4048b61c1013f6a7c66e";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "56becf07105fbacd2b70f87f3f696cfbed226cb48d6d89ed7f65ba4acae3f2f8";
    };
  };
}