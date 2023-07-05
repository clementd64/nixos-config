{ config, lib, pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./dunst.nix
    ./fish.nix
    ./git.nix
    ./htop.nix
    ./i3.nix
    ./nvim.nix
    ./rofi.nix
    ./ssh-agent.nix
    ./starship.nix
    ./tmux.nix
    ./vscode
  ];

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
  home.packages = with pkgs; [
    ansible
    ansible-lint
    dbeaver
    discord
    neofetch
    signal-desktop
    skypeforlinux
    telegram-desktop
    thunderbird
    tmux
  ];
}
