{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.0-alpha2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "90cfb45685c124e88d8bb2d59061468177b23666c74214b1aaedf4f2e398d977";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "071edcd082320f730374eff91aa30d5a2d3e76a6dd60d58b2da74a0fd92257a3";
    };
  };
}