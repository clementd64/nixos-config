{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "f1d5c91c5877326cee5db5ef0a373af0adb9bdb0";
    hash = "sha256-uX93kaXbrmoOyw/q60YAnB5BpNawgTQJBslgYQg55qw=";
  };

  vendorHash = "sha256-5JrNNscrGpQ1OA387FValSizu7Es1w3R2cVjO7XPAnc=";

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
