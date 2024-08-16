{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "flyctl";
  version = "0.2.112";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "1f031d72782f3003c538ae3964e7471784d3c342bd2431a7d8784da06bada27b";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "38c55abbe7d2235b5508254482592f4c3a424dc8a9b5848fad88e21f09f238f5";
    };
  };
}