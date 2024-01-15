{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "b96c3d1235bc4fd53b199175818a35642e50cbc6b82b8422dcab59240d06d885";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "c2058c1e2f2222d81de0ad291eace3e34330cc7b74315eaacb60a5b6402527b1";
    };
  };
}