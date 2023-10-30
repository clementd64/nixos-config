{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.16.2";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "dae5e6e39107a66dc5c8ea59f6f27b16c54bd6be31f57e3281f6d87de30e05b0";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "efdd75eb5c12af6fec4189aa57dc777035a87dd57204daa52293901199569157";
    };
  };
}