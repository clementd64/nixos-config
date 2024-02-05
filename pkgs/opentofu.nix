{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  pname = "opentofu-bin";
  name = "tofu";
  version = "1.6.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_amd64.zip";
      sha256 = "2ffd88719beb6d7e30e605b20efbf9ed75547cb13e9db279fa7f5f21fcd37403";
    };
    aarch64-linux = {
      url = "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_arm64.zip";
      sha256 = "e6753e93f520debd93c5562b8f1b3a300fde755b912f15ef75994e3c3c178069";
    };
  };
}