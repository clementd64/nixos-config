{ buildGo126Module, fetchFromGitHub }:
buildGo126Module {
  pname = "proxy64";
  version = "0.0.0";

  src = fetchFromGitHub {
      owner = "clementd64";
      repo = "proxy64";
      rev = "cb98825df6200716f6d114afbc2cb03051c43338";
      hash = "sha256-iQI7nZU2nf63QMTeIN2McKZTX0RA8vPZmArdl8B0jvI=";
  };

  vendorHash = "sha256-Y/V0phjxNPTDHxslhJ6iuw27saX5931lS7njRDYySdQ=";

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
}
