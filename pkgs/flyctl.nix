{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.1.112";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "a94d7859682dc8a824cc2ccae6663bb734f996395ef5432f413320faee6e67a7";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "d6fc41629ba6b9ebc92e0c86976c03d86829b6dd8221c582f61da90403d9b8c0";
    };
  };
}