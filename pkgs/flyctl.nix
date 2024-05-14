{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.2.53";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "d5ea89e2f745bf3128a264da8fd1a692de12f0344e11bd7a2de44aada9826cd6";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "864c69c46efc7fcc98a1c0d24c37c919aafc2d44d66274e8dee55bd6b407d32b";
    };
  };
}