{ fetchStaticBinary }:
fetchStaticBinary rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.8.2";
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.tar.gz";
      sha256 = "9f43888571cbe9cdfe03e81c6cbb93b4aacc014db19373a4e7608aaa7df111d1";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.tar.gz";
      sha256 = "b8d47c08228ea66bb42df02e7559435e3858b75e30e2921f9ef83bf5b43b0c70";
    };
  };
}