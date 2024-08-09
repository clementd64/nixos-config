{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "helm";
  version = "3.15.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "2694b91c3e501cff57caf650e639604a274645f61af2ea4d601677b746b44fe2";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "adcf07b08484b52508e5cbc8b5f4b0b0db50342f7bc487ecd88b8948b680e6a7";
      path = "linux-arm64/helm";
    };
  };
}