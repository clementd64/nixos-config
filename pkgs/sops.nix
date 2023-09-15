{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "sops";
  version = "3.8.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.amd64";
      sha256 = "48fb4a6562014a9213be15b4991931266d040b9b64dba8dbcd07b902e90025c0";
    };
    aarch64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.arm64";
      sha256 = "5ec31eaed635e154b59ff4b7c9b311b6e616bd4818a68899c2f9db00c81e3a63";
    };
  };
}