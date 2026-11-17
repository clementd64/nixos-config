{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "92d64445ae50c0dec54a3beade5e299feaf77774";
    hash = "sha256-BEj/MEK6oC36u5MbRa2DkVMh/tnj+z1tjyauy7vx28s=";
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
