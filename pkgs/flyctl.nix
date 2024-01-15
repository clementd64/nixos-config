{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.1.141";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_x86_64.tar.gz";
      sha256 = "a09c7c538e62368d8a9b50f2ec227827d1b0f018d867a51e3cc9e7528ac3f4aa";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "d1aa013621532436397e0d9d2421d5f642b3619f99f173882eead5d25bc282fd";
    };
  };
}