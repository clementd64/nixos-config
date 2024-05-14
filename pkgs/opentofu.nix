{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.7.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.tar.gz";
      sha256 = "f46e20191635b1f98fa61969301c6fe87706bf36b0d34c74083ccb454d2bba1f";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.tar.gz";
      sha256 = "06e86edeb0f233a9db74aa59eb1f434ae2a71874a986f08b1299d81808aa93f6";
    };
  };
}