{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "flux";
  pname = "fluxcd-bin";
  version = "2.1.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_amd64.tar.gz";
      sha256 = "61b360b50d6cfc34410730b1cebeb75f5eda2b484e47b9a083412f51ad56de68";
    };
    aarch64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_arm64.tar.gz";
      sha256 = "c92ea535cc7a458c4153fbd167c2c00c49cb7d8ed41b8dfbecdbcb68a33d6a9c";
    };
  };
}