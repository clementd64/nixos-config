{ buildGo123Module, fetchFromGitHub }:
buildGo123Module {
  pname = "proxy64";
  version = "0.0.0";

  src = fetchFromGitHub {
      owner = "clementd64";
      repo = "proxy64";
      rev = "fe384ed96116d83b98a07c78e759f5f03361621a";
      hash = "sha256-8rWy/AQOCtU55T+S3BaT97YOUVUQN8Hkf78+sf98pL4=";
  };

  vendorHash = null;

  CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
}
