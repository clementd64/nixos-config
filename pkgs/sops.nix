{ callPackage }:
callPackage ../lib/fetchStaticBinary.nix rec {
  name = "sops";
  version = "3.9.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.amd64";
      sha256 = "0d65660fbe785647ff4f1764d7f69edf598f79d6d79ebbef4a501909b6ff6b82";
    };
    aarch64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.arm64";
      sha256 = "596f26de6d4f7d1cc44f9e27bfea3192ef77f810f31f3f4132a417860ab91ebc";
    };
  };
}