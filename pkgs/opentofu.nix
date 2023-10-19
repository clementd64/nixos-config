{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.0-alpha3";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "bb1b65d5bffea4e1f840af2c32290d4c11ca27e3c55a386da89f5f014cf33196";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "2b94de7dd206610e0d0d32d216c4001d32cea6bfe35a1b4630db5f17d92f03e3";
    };
  };
}