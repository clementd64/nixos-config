{ buildGo126Module, fetchFromGitHub }:
buildGo126Module {
  pname = "proxy64";
  version = "0.0.0";

  src = fetchFromGitHub {
      owner = "clementd64";
      repo = "proxy64";
      rev = "84f7903549b0934843fb1cfa903668ea0e14a74a";
      hash = "sha256-kd2Oq3Cx3P4c5yxA5NAwbRC0s40d354fS/H2ldX/CaM=";
  };

  vendorHash = null;

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
}
