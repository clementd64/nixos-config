{ buildGo126Module, fetchFromGitHub }:
buildGo126Module {
  pname = "proxy64";
  version = "0.0.0";

  src = fetchFromGitHub {
      owner = "clementd64";
      repo = "proxy64";
      rev = "32375fc666d9607e788834b6bff9a50b7784ab20";
      hash = "sha256-BTlmpzYueG8NHtgsEztKmeda+yGcDnNUw5huvdhECTg=";
  };

  vendorHash = "sha256-Y/V0phjxNPTDHxslhJ6iuw27saX5931lS7njRDYySdQ=";

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
}
