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
    docker
    docker-buildx
    docker-compose
    docker-proxy
    eza
    gh
    go
    keepassxc
    nodejs_20
    osu-lazer-bin
    prismlauncher
    rclone
    signal-desktop
    tailscale
    telegram-desktop
    vscode
    zls;
}
