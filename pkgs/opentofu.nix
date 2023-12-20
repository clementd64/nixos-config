{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.0-rc1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "c810fa64d7147df4272681360ef5bc9a366e574bfdabd6b88b18e2c36c3b1aee";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "c04c52c5afd4a0417fcf9c7ad0d7ff05748983549ae830ee451ba77de0bd776c";
    };
  };
}