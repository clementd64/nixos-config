{ pkgs-unstable }:
prev: final:
{
  inherit (pkgs-unstable)
    age
    ansible
    ansible-lint
    dbeaver
    deno
    discord
    gh
    go
    keepassxc
    nodejs_20
    prismlauncher
    signal-desktop
    skypeforlinux
    tailscale
    telegram-desktop
    vscode;
}