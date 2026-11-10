{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "7136915a084c13fc43816712661719a29024f7de";
    hash = "sha256-yy5yL3iGxKkUu/GsFcxvpFda4fQ7rO5fHV4CSSfEEUQ=";
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
