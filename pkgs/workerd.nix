{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "workerd";
  version = "1.20240815.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/cloudflare/workerd/releases/download/v${version}/workerd-linux-64.gz";
      sha256 = "9ad4d8f3b2eb20acfa0f625594fa977a94a1dc19fbbb2fe6c4fdb86e3b15c948";
    };
    aarch64-linux = {
      url = "https://github.com/cloudflare/workerd/releases/download/v${version}/workerd-linux-arm64.gz";
      sha256 = "f95b860f820e3260efda16aecafc812cb283390f94dbf1496dfba13dbea2a46d";
    };
  };
}
