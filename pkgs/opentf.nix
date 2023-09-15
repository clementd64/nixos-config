{ buildGoModule
, fetchFromGitHub
, coreutils
, installShellFiles
}:

let
  mkOpenTf = { version, hash, vendorHash ? null, rev, ... }@attrs:
    let attrs' = builtins.removeAttrs attrs [ "version" "hash" "vendorHash" "rev" ];
    in
    buildGoModule ({
      pname = "opentf";
      inherit version vendorHash;

      src = fetchFromGitHub {
        owner = "opentffoundation";
        repo = "opentf";
        inherit hash rev;
      };

      ldflags = [ "-s" "-w" ];

      postConfigure = ''
        # speakeasy hardcodes /bin/stty https://github.com/bgentry/speakeasy/issues/22
        substituteInPlace vendor/github.com/bgentry/speakeasy/speakeasy_unix.go \
          --replace "/bin/stty" "${coreutils}/bin/stty"
      '';

      nativeBuildInputs = [ installShellFiles ];

      postInstall = ''
        # https://github.com/posener/complete/blob/9a4745ac49b29530e07dc2581745a218b646b7a3/cmd/install/bash.go#L8
        installShellCompletion --bash --name opentf <(echo complete -C opentf opentf)
        cat > opentf.fish <<EOF
        function __complete_opentf
            set -lx COMP_LINE (commandline -cp)
            test -z (commandline -ct)
            and set COMP_LINE "$COMP_LINE "
            opentf
        end
        complete -f -c opentf -a "(__complete_opentf)"
        EOF
        installShellCompletion opentf.fish
      '';

      preCheck = ''
        export HOME=$TMPDIR
        export TF_SKIP_REMOTE_TESTS=1
      '';

      subPackages = [ "." ];
    } // attrs');
in
mkOpenTf rec {
  version = "1.6.0-dev";
  hash = "sha256-SbGfKzCTv9K+gSZAqVJfwapjBp5xtK88ePJfmP/rsd8=";
  vendorHash = "sha256-7GLmgdESm28PTB+aK/9vjCk0JGA2dA5KUCXr2a4iLEw=";
  rev = "a4f9c632881c9cfab3ba53d690d2ae369e594105";
}
