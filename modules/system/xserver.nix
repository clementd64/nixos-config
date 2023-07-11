{ config, lib, pkgs, ... }:

let cfg = config.clement.xserver;
in with lib; {
  options.clement.xserver = {
    enable = mkEnableOption "Enable xserver";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      layout = "fr";
      xkbVariant = "oss";
      xkbOptions = "caps:none";

      libinput = {
        enable = true;
        # Make the touchpad usable
        touchpad = {
          clickMethod = "clickfinger";
          naturalScrolling = true;
        };
      };

      desktopManager.xterm.enable = false;

      displayManager = {
        defaultSession = "none+i3";
        lightdm.enable = true;
        autoLogin.enable = true;
        autoLogin.user = "clement";
      };

      windowManager.i3 = {
        enable = true;
      };
    };

    fonts.fonts = with pkgs; [
      fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];

    programs.dconf.enable = true;
  };
}