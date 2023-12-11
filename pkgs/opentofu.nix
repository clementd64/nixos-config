{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.0-beta3";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "c1e6720fdc6b343d3df0ab6f4e80512518e73bf9615f1dd63c47985c85ff5b29";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "67eab571b59f0551dce78a93d7bf8d219aecf651b7476d06c4f93a3d66bad68e";
    };
  };
}