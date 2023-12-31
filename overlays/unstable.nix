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
    docker-buildx
    docker-compose
    docker-proxy
    eza
    gh
    go
    gvisor
    keepassxc
    nodejs_20
    osu-lazer-bin
    prismlauncher
    rclone
    signal-desktop
    skypeforlinux
    tailscale
    telegram-desktop
    vscode
    zls;

  docker = pkgs-unstable.docker_24;
}
