{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "flyctl";
  version = "0.2.84";
  aliases = [ "fly" ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_amd64.tar.gz";
      sha256 = "0038c82d4177879048aa98e13ce2708fe1536e8955fb1c5319c3192a4d491c2e";
    };
    aarch64-linux = {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_Linux_arm64.tar.gz";
      sha256 = "ed4d9fb6678bed766f3351664bfec9c2af51079affb9f1201e428d31092d9ebb";
    };
  };
}