{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.16.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "492387572bb2c4de904fa400636e05492e7200b331335743d46f2f2874150162";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "434d77b8079a27f303d30758ad99152abf3102095b6bb3573c1de307f1ab6345";
    };
  };
}