{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "flux";
  pname = "fluxcd-bin";
  version = "2.2.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_amd64.tar.gz";
      sha256 = "292945a94ae370b91fe004e1f41b16063fc87371a61a1fd29958dfd959140a60";
    };
    aarch64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_arm64.tar.gz";
      sha256 = "345e2c0ec4b126d2102604b030d4a48819e00a9b66b4de064361103c6b51a018";
    };
  };
}