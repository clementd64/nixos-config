{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "d637905519c25ddb1cd9d426c27548510562ead6";
    hash = "sha256-JfEUgM7L9K2Gkgpm4MixZvQz2MHbSAkyrfGvMvLmFy0=";
  };

  vendorHash = "sha256-LSmVQRyPhiYIAsfBpKLiKTU9VjlCQdNzpG44ei0sDgI=";

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
