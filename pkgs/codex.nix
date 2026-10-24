{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "36e3a945f62d1aef0c6b761fe6c8cbfd4bbc4485";
    hash = "sha256-DQ6OCqPdPYwqhWGotJFnaU3WCos7LIxg4cPvpXWmpjU=";
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
