{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "helm";
  version = "3.16.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "e57e826410269d72be3113333dbfaac0d8dfdd1b0cc4e9cb08bdf97722731ca9";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "780b5b86f0db5546769b3e9f0204713bbdd2f6696dfdaac122fbe7f2f31541d2";
      path = "linux-arm64/helm";
    };
  };
}