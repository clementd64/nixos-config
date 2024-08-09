{ fetchStaticBinary }:
fetchStaticBinary rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.8.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.tar.gz";
      sha256 = "cb54a998eae5dc5890a8d1adacf9b6fe396a57fc6257a9154ccdebb3035b63b8";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.tar.gz";
      sha256 = "0efb30592f8df710440dccb4447c7e1c8e9a66135dc2d93d8f13e2039c95ae26";
    };
  };
}