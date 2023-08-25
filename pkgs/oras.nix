{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "oras";
  version = "1.0.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/oras-project/oras/releases/download/v${version}/oras_${version}_linux_amd64.tar.gz";
      sha256 = "6b51b87360d373dd3c19b91d2627d2efd320513380a878b6f06702f72fe8c5ab";
    };
    aarch64-linux = {
      url = "https://github.com/oras-project/oras/releases/download/v${version}/oras_${version}_linux_arm64.tar.gz";
      sha256 = "352a5b21d5840418c7710fa55db9881d46a4c3e2c0fdb14672f9df38ba66dd3d";
    };
  };
}