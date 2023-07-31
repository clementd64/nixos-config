{ config, lib, pkgs, pkgs-unstable, ... }:
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
    tools.enable = true;
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

  home.packages = (with pkgs; [
    neofetch
    thunderbirdPackages.thunderbird-115
    vlc
    wireguard-tools
  ]) ++ (with pkgs-unstable; [
    discord
    keepassxc
    signal-desktop
    skypeforlinux
    telegram-desktop
  ]);

  home.stateVersion = "23.05";
}
