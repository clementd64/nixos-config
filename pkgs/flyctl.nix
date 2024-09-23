{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "flyctl";
  version = "0.3.2";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "380a4b5ea083107dcf101d56f4ad3913239aa9ccfe38e7c6b2c8f02856371c60";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "63e04ba48dd6a87c6a5175b8e5104fcf22843af608e364c078d0b528856e6504";
    };
  };
}