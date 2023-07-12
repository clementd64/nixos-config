{ config, lib, pkgs, ... }:

let cfg = config.clement.rofi;
in with lib; {
  options.clement.rofi = {
    enable = mkEnableOption "Enable rofi";

    size = mkOption {
      type = types.int;
      default = 16;
    };
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
      ];

      font = "Fira Code ${toString cfg.size}";
      location = "bottom";
      yoffset = -105;

      extraConfig = {
        modi = "run,calc,filebrowser";
      };

      theme =
        let
          # Use `mkLiteral` for string-like values that should show without
          # quotes, e.g.:
          # {
          #   foo = "abc"; => foo: "abc";
          #   bar = mkLiteral "abc"; => bar: abc;
          # };
          inherit (config.lib.formats.rasi) mkLiteral;
        in {
          "*" = {
            foreground = mkLiteral "#f8f8f2";
            background-color = mkLiteral "#282a36";
            active-background = mkLiteral "#6272a4";
            urgent-background = mkLiteral "#ff5555";
            urgent-foreground = mkLiteral "#282a36";
            selected-background = mkLiteral "@active-background";
            selected-urgent-background = mkLiteral "@urgent-background";
            selected-active-background = mkLiteral "@active-background";
            separatorcolor = mkLiteral "@active-background";
            bordercolor = mkLiteral "@active-background";
          };

          "#window" = {
            background-color = mkLiteral "@background-color";
            border = 1;
            border-radius = 6;
            border-color = mkLiteral "@bordercolor";
            padding = 5;
          };

          "#mainbox" = {
            border = 0;
            padding = 0;
          };

          "#message" = {
            border = mkLiteral "1px dash 0px 0px";
            border-color = mkLiteral "@separatorcolor";
            padding = mkLiteral "1px";
          };

          "#textbox" = {
            text-color = mkLiteral "@foreground";
          };

          "#listview" = {
            fixed-height = 0;
            border = mkLiteral "2px dash 0px 0px";
            border-color = mkLiteral "@bordercolor";
            spacing = mkLiteral "2px";
            scrollbar = mkLiteral "false";
            padding = mkLiteral "2px 0px 0px";
          };

          "#element" = {
            border = 0;
            padding = mkLiteral "1px";
          };

          "#element.normal.normal" = {
            background-color = mkLiteral "@background-color";
            text-color = mkLiteral "@foreground";
          };

          "#element.normal.urgent" = {
            background-color = mkLiteral "@urgent-background";
            text-color = mkLiteral "@urgent-foreground";
          };

          "#element.normal.active" = {
            background-color = mkLiteral "@active-background";
            text-color = mkLiteral "@foreground";
          };

          "#element.selected.normal" = {
            background-color = mkLiteral "@selected-background";
            text-color = mkLiteral "@foreground";
          };

          "#element.selected.urgent" = {
            background-color = mkLiteral "@selected-urgent-background";
            text-color = mkLiteral "@foreground";
          };

          "#element.selected.active" = {
            background-color = mkLiteral "@selected-active-background";
            text-color = mkLiteral "@foreground";
          };

          "#element.alternate.normal" = {
            background-color = mkLiteral "@background-color";
            text-color = mkLiteral "@foreground";
          };

          "#element.alternate.urgent" = {
            background-color = mkLiteral "@urgent-background";
            text-color = mkLiteral "@foreground";
          };

          "#element.alternate.active" = {
            background-color = mkLiteral "@active-background";
            text-color = mkLiteral "@foreground";
          };

          "#scrollbar" = {
            width = mkLiteral "2px";
            border = 0;
            handle-width = mkLiteral "8px";
            padding = 0;
          };

          "#sidebar" = {
            border = mkLiteral "2px dash 0px 0px";
            border-color = mkLiteral "@separatorcolor";
          };

          "#button.selected" = {
            background-color = mkLiteral "@selected-background";
            text-color = mkLiteral "@foreground";
          };

          "#inputbar" = {
            spacing = 0;
            text-color = mkLiteral "@foreground";
            padding = mkLiteral "1px";
          };

          "#case-indicator" = {
            spacing = 0;
            text-color = mkLiteral "@foreground";
          };

          "#entry" = {
            spacing = 0;
            text-color = mkLiteral "@foreground";
          };

          "#prompt" = {
            spacing = 0;
            text-color = mkLiteral "@foreground";
          };

          "#inputbar" = {
            children = map mkLiteral [ "prompt" "textbox-prompt-colon" "entry" "case-indicator" ];
          };

          "#textbox-prompt-colon" = {
            expand = mkLiteral "false";
            str = ":";
            margin = mkLiteral "0px 0.3em 0em 0em";
            text-color = mkLiteral "@foreground";
          };

          "element-text, element-icon" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };
        };
    };
  };
}

