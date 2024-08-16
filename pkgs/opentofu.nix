{ fetchStaticBinary }:
fetchStaticBinary rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.8.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.tar.gz";
      sha256 = "65f6cc8f763275bc5b58749e5214a8c483842bb490704554c0440946faf89bb2";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.tar.gz";
      sha256 = "5c5c7d57c8fd6d0ca1b9a55037675e51946a356fc5a05599517cd1f10d2006d9";
    };
  };
}