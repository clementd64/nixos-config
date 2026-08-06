{ config, lib, pkgs, ... }:
{
  # TODO: Add missing wallpaper

  # TODO: migrate end of ./users/clement as module
  imports = [
    ../../users/clement/i3.nix
  ];

  clement = {
    alacritty.enable = true;
    dunst.enable = true;
    fish.enable = true;
    ghostty.enable = true;
    git.enable = true;
    helix.enable = true;
    htop.enable = true;
    neovim.enable = true;
    rofi.enable = true;
    starship.enable = true;
    tmux.enable = true;
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
  gtk.gtk4.theme.name = "Adwaita-dark";
  qt.enable = true;
  qt.style.name = "adwaita-dark";

  services.ssh-agent.enable = true;
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  systemd.user.services.fehbg = {
    Unit = {
      Description = "Update wallpaper";
      ConditionPathExists = "%h/.fehbg";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.fehbg";
    };
  };

  systemd.user.timers.fehbg = {
    Unit.Description = "Update wallpaper";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.packages = with pkgs; [
    androidenv.androidPkgs.platform-tools
    dbeaver-bin
    discord
    factorio
    factorio-env
    keepassxc
    mapshot
    opentofu
    osu-lazer-bin
    prismlauncher
    pulseaudio # TMP need pipewire alternative
    signal-desktop
    telegram-desktop
    thunderbird
    vlc
    wireguard-tools
  ];

  home.stateVersion = "26.05";
}
