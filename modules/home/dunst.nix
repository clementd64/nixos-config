{ config, lib, ... }:

let cfg = config.clement.dunst;
in with lib; {
  options.clement.dunst = {
    enable = mkEnableOption "Enable dunst";

    size = mkOption {
      type = types.int;
      default = 12;
    };
  };

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
            offset = "15x49";
            font = "Fira Code ${toString cfg.size}";
            separator_height = 3;
            line_height = 3;
            alignment = "center";
            vertical_alignment = "center";
            corner_radius = 5;
        };

        urgency_low = {
            frame_color = "#3B7C87";
            foreground = "#3B7C87";
            background = "#191311";
            timeout = 4;
        };

        urgency_normal = {
            frame_color = "#5B8234";
            foreground = "#5B8234";
            background = "#191311";
            timeout = 6;
        };

        urgency_critical = {
            frame_color = "#B7472A";
            foreground = "#B7472A";
            background = "#191311";
            timeout = 8;
        };
      };
    };
  };
}