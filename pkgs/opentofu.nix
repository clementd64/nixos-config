{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.0-alpha5";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "b245b51f9502af2932f4b5d230c14d43f644bb58be65246cfc13fd6c32505195";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "4c32eebb62b43637e7ec2dcc2347e64e4587b0bfe544ea097e8bc1c3473391a0";
    };
  };
}