{ config, lib, pkgs, pkgs-unstable, pkgs-2305, ... }:
{
  # TODO: Add missing wallpaper

  # TODO: migrate end of ./users/clement as module
  imports = [
    ../../users/clement/i3.nix
    ../../users/clement/tmux.nix
  ];

  clement = {
    alacritty.enable = true;
    dunst.enable = true;
    fish.enable = true;
    git.enable = true;
    htop.enable = true;
    neovim.enable = true;
    rofi.enable = true;
    ssh-agent.enable = true;
    starship.enable = true;
    vscode.enable = true;
  };

  programs.chromium.enable = true;
  programs.chromium.commandLineArgs = [
    "--force-dark-mode"
    "--enable-features=WebUIDarkMode"
  ];

  gtk.enable = true;
  gtk.theme.name = "Adwaita-dark";
  qt.enable = true;
  qt.style.name = "adwaita-dark";

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  home.stateVersion = "23.05";
  home.packages = (with pkgs; [
    dig
    gcc
    gnumake
    jq
    ldns
    neofetch
    openssl
    python311
    # thunderbird 115 not in commit before Go 1.20.6 (Docker regression)
    # thunderbirdPackages.thunderbird-115
    tmux
    wireguard-tools
  ]) ++ (with pkgs-unstable; [
    ansible
    ansible-lint
    dbeaver
    deno
    discord
    fluxcd
    go
    keepassxc
    kind
    kubectl
    kubernetes-helm
    minikube
    nodejs_20
    signal-desktop
    skypeforlinux
    sops
    telegram-desktop
    terraform
    vcluster
  ]) ++ [ pkgs-2305.thunderbirdPackages.thunderbird-115 ];
}
