{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.1.104";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "28c29ac8d05125b1f522e9740f2e5d7e27c76766d9cc1417e245e0da8a3ef4a8";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "e21d7305db25e129409806be74488e03759ea9fb6368db7c25f9870e1b768905";
    };
  };
}