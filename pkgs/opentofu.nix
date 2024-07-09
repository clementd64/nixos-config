{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.7.2";
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.tar.gz";
      sha256 = "c601cffe874db3634c4413602e3fa08aded2b70110ea9073733d1bad81377e7b";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.tar.gz";
      sha256 = "ee7ab4ed7eda026d8ac451a2202ede90e387cb634d0fca61d7f5b2a406e8303b";
    };
  };
}