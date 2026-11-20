{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "4d3f7fa283e4d8d7851d035f5d7c2eabb787e571";
    hash = "sha256-7vM8PQJI0jf/A2UutSQHYm4mi4PeCnTWmjdlA/uIh0k=";
  };

  vendorHash = "sha256-iIA9LjNtl8Hgk9nZSKpUd5XdFj1/CRpm7Wy71x54LhE=";

  frontend = buildNpmPackage {
    inherit (finalAttrs) pname version src;
    env = frontendEnv;

    npmDepsHash = "sha256-mKbhcgPWg+QOkFELn9xTIr92Oq9IM5ZbI8scoTfXew4=";
    npmDepsFetcherVersion = 2;
    npmWorkspace = "packages/front";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r packages/front/dist/. $out/

      runHook postInstall
    '';
  };

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" "-X" "github.com/clementd64/codex/internal/cmd.FrontPath=${finalAttrs.frontend}" ];
})
