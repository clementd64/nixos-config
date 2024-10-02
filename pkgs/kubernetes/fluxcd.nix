{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "flux";
  pname = "fluxcd-bin";
  version = "2.4.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_amd64.tar.gz";
      sha256 = "7b70b75af20e28fc30ee66cf5372ec8d51dd466fd2ee21aa42690984de70b09b";
    };
    aarch64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_arm64.tar.gz";
      sha256 = "4b8c95a1e8ad262dd33a67d28e22979cf3e022a9283d4676763b6728247d92a0";
    };
  };
}