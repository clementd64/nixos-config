{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "flyctl";
  version = "0.3.14";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "3a943208dc36990a833787283aca710039072e099c1ba5bd27813d27c6f6a091";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "bdb9384ca98fcc73b90d3994f5964f5c1a4ecb0cb68972a58479b333ff50e494";
    };
  };
}