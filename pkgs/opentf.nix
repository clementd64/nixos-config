{ buildGoModule
, fetchFromGitHub
, coreutils
, installShellFiles
}:

let
  mkOpenTf = { version, hash, vendorHash ? null, ... }@attrs:
    let attrs' = builtins.removeAttrs attrs [ "version" "hash" "vendorHash" ];
    in
    buildGoModule ({
      pname = "opentf";
      inherit version vendorHash;

      src = fetchFromGitHub {
        owner = "opentffoundation";
        repo = "opentf";
        rev = "e8c1c3a7007394111d610acc1015be73f8776398";
        inherit hash;
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
mkOpenTf {
  version = "1.6.0-dev";
  hash = "sha256-k4DW55moxrEVeMJiZFczN9JiLInJ6GkacIRPRz2H63w=";
  vendorHash = "sha256-ew3wpAd4R5agEyv4/F/dTHouM7DpUezQC0YBDpTA3Wg=";
}