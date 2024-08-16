{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "helm";
  version = "3.15.4";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "11400fecfc07fd6f034863e4e0c4c4445594673fd2a129e701fe41f31170cfa9";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "fa419ecb139442e8a594c242343fafb7a46af3af34041c4eac1efcc49d74e626";
      path = "linux-arm64/helm";
    };
  };
}