{ buildGo127Module, buildNpmPackage, fetchFromGitHub, frontendEnv ? {} }:
buildGo127Module (finalAttrs: {
  pname = "codex";
  version = "latest";

  src = fetchFromGitHub {
    owner = "clementd64";
    repo = "codex";
    rev = "b5feff1cfb44dfb2f91a51ea8aaa22987c82cd1b";
    hash = "sha256-oVU2hHsSPBfgnqaYH/I+rsb8J0GTuSasMCIOp94/5Wc=";
  };

  vendorHash = "sha256-LSmVQRyPhiYIAsfBpKLiKTU9VjlCQdNzpG44ei0sDgI=";

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

  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" "-X" "github.com/clementd64/codex/internal/cmd.FrontPath=${finalAttrs.frontend}" ];
})
