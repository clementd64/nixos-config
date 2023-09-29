{ buildGoModule
, fetchFromGitHub
, coreutils
, installShellFiles
}:

let
  mkOpenTofu = { version, hash, vendorHash ? null, rev, ... }@attrs:
    let attrs' = builtins.removeAttrs attrs [ "version" "hash" "vendorHash" "rev" ];
    in
    buildGoModule ({
      pname = "opentofu";
      inherit version vendorHash;

      src = fetchFromGitHub {
        owner = "opentofu";
        repo = "opentofu";
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
        installShellCompletion --bash --name tofu <(echo complete -C tofu tofu)
        cat > tofu.fish <<EOF
        function __complete_tofu
            set -lx COMP_LINE (commandline -cp)
            test -z (commandline -ct)
            and set COMP_LINE "$COMP_LINE "
            tofu
        end
        complete -f -c tofu -a "(__complete_tofu)"
        EOF
        installShellCompletion tofu.fish
      '';

      preCheck = ''
        export HOME=$TMPDIR
        export TF_SKIP_REMOTE_TESTS=1
      '';

      subPackages = [ "cmd/tofu" ];
    } // attrs');
in
mkOpenTofu rec {
  version = "1.6.0-dev";
  hash = "sha256-V5i4PQiLBgTXzpWUpiqn9nf9+ddXI7330ZO9yaSxPbg=";
  vendorHash = "sha256-wKy2q5EVwipHGT2upT+w0Ri2wuXtiJsdSHnmM01BKjc=";
  rev = "6cd1c00e1dac8df9427927eb6f31f601a6966c49";
}
