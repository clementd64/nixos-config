{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.1.147";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "73b55a6b903c49a82249c107a06818303e795666aa7c586afcb102cb5d9d0e69";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "a4408355de87b262064410cf8bb1ffe30717441f63b1614a5ea43ba1ee180f86";
    };
  };
}