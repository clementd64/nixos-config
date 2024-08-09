{ callPackage }:
callPackage ../lib/fetchStaticBinary.nix rec {
  name = "workerd";
  version = "1.20240729.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/cloudflare/workerd/releases/download/v${version}/workerd-linux-64.gz";
      sha256 = "93445dd3100dc04a1a3e41d5a1379a093e4b97f816f59903aff64ea7eb49f111";
    };
    aarch64-linux = {
      url = "https://github.com/cloudflare/workerd/releases/download/v${version}/workerd-linux-arm64.gz";
      sha256 = "41f1fba9e1f1cdafbf4e1ffea2ec50800fe9b82ed9915c0d362d6e008d56df76";
    };
  };
}
