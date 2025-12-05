{ buildGo125Module, fetchFromGitHub }:
buildGo125Module {
  pname = "proxy64";
  version = "0.0.0";

  src = fetchFromGitHub {
      owner = "clementd64";
      repo = "proxy64";
      rev = "fac05b4deb44e53206db480895f240a5dea43f43";
      hash = "sha256-9t4qbpUXgXAl9zzYhaaqsce+kiv1SGm/YqHfU4eFhuY=";
  };

  vendorHash = null;

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
}
