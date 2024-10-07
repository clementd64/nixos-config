{ fetchStaticBinary }:
fetchStaticBinary rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.8.3";
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.tar.gz";
      sha256 = "77f3cecf737d1b4f09087c1417836e8fdc32080b59daa37bbf1bf736b80cd3b4";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.tar.gz";
      sha256 = "1e21904ce69f2acfe1515cb86182ee12b6e14e934418001b6667a238921249e5";
    };
  };
}