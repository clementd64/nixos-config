{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "d45cd5193b74001d2ba4525cc89d05b16f76f629";
    hash = "sha256-7Eqt8STQdJVJIBU+2H791QmgFJDBorzCl2Co16VqfGY=";
  };

  vendorHash = "sha256-isyogLsnWcBGpO439Lc9W2vQMAe11XtqBSGdSreuNLM=";

  frontend = buildNpmPackage {
    inherit (finalAttrs) pname version src;
    env = frontendEnv;

    npmDepsHash = "sha256-jWOdXElTP2o9Jv29JAHKQithf9HMBY6GUPiDKxT3dJc=";
    npmDepsFetcherVersion = 2;
    npmWorkspace = "packages/front";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r packages/front/dist/. $out/

      runHook postInstall
    '';
  };

  preBuild = ''
    mkdir -p packages/front/dist
    cp -r ${finalAttrs.frontend}/. packages/front/dist/
  '';

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
})
