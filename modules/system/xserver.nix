{ config, lib, pkgs, ... }:

let cfg = config.clement.xserver;
in with lib; {
  options.clement.xserver = {
    enable = mkEnableOption "xserver";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "fr";
        options = "caps:none";
        variant = "oss";
      };

      desktopManager.xterm.enable = false;

      displayManager = {
        lightdm.enable = true;
      };

      windowManager.i3 = {
        enable = true;
      };
    };

    services.libinput = {
      enable = true;
      # Make the touchpad usable
      touchpad = {
        clickMethod = "clickfinger";
        naturalScrolling = true;
      };
    };

    services.displayManager = {
      defaultSession = "none+i3";
      autoLogin.enable = true;
      autoLogin.user = "clement";
    };

    fonts.packages = with pkgs; [
      fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    programs.dconf.enable = true;
    services.autorandr.enable = true;
  };
}