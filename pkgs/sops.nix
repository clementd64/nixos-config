{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "sops";
  version = "3.8.0-rc.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.amd64";
      sha256 = "84ce5a0c16edd045f9db18ea6a447e0d940caffafe49f986b568f9ba4ea4d2c4";
    };
    aarch64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.arm64";
      sha256 = "5798fdb433f89050e65a7181e4b888df0ab225ce950f0d9b035840c980049022";
    };
  };
}