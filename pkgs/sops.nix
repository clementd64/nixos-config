{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "sops";
  version = "3.8.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.amd64";
      sha256 = "d6bf07fb61972127c9e0d622523124c2d81caf9f7971fb123228961021811697";
    };
    aarch64-linux = {
      url = "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.arm64";
      sha256 = "15b8e90ca80dc23125cd2925731035fdef20c749ba259df477d1dd103a06d621";
    };
  };
}