{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "flux";
  pname = "fluxcd-bin";
  version = "2.2.3";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_amd64.tar.gz";
      sha256 = "9a705df552df5ac638f93d7fc43d9d8cda6a78f01a16736ae6f355f4a84ebdb3";
    };
    aarch64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_arm64.tar.gz";
      sha256 = "a8dcf688296aedec3225fb2c183c9e2ce3bda26788d10f9d01ddb7bdb5b55288";
    };
  };
}