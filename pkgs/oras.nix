{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "oras";
  version = "1.1.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/oras-project/oras/releases/download/v${version}/oras_${version}_linux_amd64.tar.gz";
      sha256 = "e09e85323b24ccc8209a1506f142e3d481e6e809018537c6b3db979c891e6ad7";
    };
    aarch64-linux = {
      url = "https://github.com/oras-project/oras/releases/download/v${version}/oras_${version}_linux_arm64.tar.gz";
      sha256 = "e450b081f67f6fda2f16b7046075c67c9a53f3fda92fd20ecc59873b10477ab4";
    };
  };
}