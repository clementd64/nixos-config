{ buildGo126Module, fetchFromGitHub }:
buildGo126Module {
  pname = "proxy64";
  version = "0.0.0";

  src = fetchFromGitHub {
      owner = "clementd64";
      repo = "proxy64";
      rev = "965b4f2d9f764a5061c9dd76e9c948b6237e8cfd";
      hash = "sha256-Mb/xsqiwh7tJS2yPoN+mpJqK30cq1c2U5+i6xWno6nM=";
  };

  vendorHash = "sha256-Y/V0phjxNPTDHxslhJ6iuw27saX5931lS7njRDYySdQ=";

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
}
