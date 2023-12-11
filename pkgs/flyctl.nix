{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.1.134";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "ca9beba0d3cc7bcc20251c9398885a4e457fea645f82a40e4b4d15bdf19d2cb2";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "f302ce5f452ca08883c3c122676e80229881e2c137d7869700d0dbd34ff55dc5";
    };
  };
}