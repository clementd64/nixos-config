{ pkgs, ... }:
{
  xdg.configFile."i3" = {
    source = ./i3;
  };

  # i3 installed system wide
  home.packages = with pkgs; [
    arandr
    brightnessctl
    feh
    i3lock
    i3status
    imagemagick
    libnotify
    lm_sensors
    maim
    playerctl
    xclip
    xss-lock
  ];

  # TODO: migrate to home-manager config
  # xsession.windowManager.i3 = {
  #   enable = true;
  # };
}
