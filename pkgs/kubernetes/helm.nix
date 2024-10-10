{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "helm";
  version = "3.16.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "9318379b847e333460d33d291d4c088156299a26cd93d570a7f5d0c36e50b5bb";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "1888301aeb7d08a03b6d9f4d2b73dcd09b89c41577e80e3455c113629fc657a4";
      path = "linux-arm64/helm";
    };
  };
}