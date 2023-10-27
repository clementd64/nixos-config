{ config, lib, ... }:

# ghostty is current not installed with nix.
# To install it manually:
# $ git clone git@github.com:mitchellh/ghostty.git
# $ cd ghostty
# $ direnv allow # enter nix shell
# $ zig build -p $HOME/.local -Doptimize=ReleaseFast

let
  cfg = config.clement.ghostty;

  # TODO: handle repetable options like "palette"
  mkValueString = with lib; value:
    if isBool value then
      if value then "true" else "false"
    else if isInt value then
      toString value
    else if isString value then
      value
    else
      abort "Unhandled value type ${builtins.typeOf value}";

  defaultConfig = {
    "font-family" = "Fira Code";
    "font-size" = cfg.fontSize;

    "background" = "0d1117";
    "foreground" = "b3b1ad";

    # black
    "palette=0" = "#484f58";
    "palette=8" = "#6e7681";
    # red
    "palette=1" = "#ff7b72";
    "palette=9" = "#ffa198";
    # green
    "palette=2" = "#3fb950";
    "palette=10" = "#56d364";
    # yellow
    "palette=3" = "#d29922";
    "palette=11" = "#e3b341";
    # blue
    "palette=4" = "#58a6ff";
    "palette=12" = "#79c0ff";
    # magento / purple
    "palette=5" = "#bc8cff";
    "palette=13" = "#d2a8ff";
    # cyan / aqua
    "palette=6" = "#39c5cf";
    "palette=14" = "#39c5cf";
    # white
    "palette=7" = "#b3b1ad";
    "palette=15" = "#b3b1ad";

    "command" = "${config.xdg.configHome}/ghostty/command.sh";

    "window-decoration" = false;
    "window-padding-balance" = true;

    # No need to confim the close as tmux is used
    "confirm-close-surface" = false;
    "gtk-single-instance" = false;
  };

in with lib; {
  options.clement.ghostty = {
    enable = mkEnableOption "Enable ghostty";

    config = mkOption {
      type = with types; types.attrsOf (oneOf [ str int bool ]);
      default = {};
    };

    fontSize = mkOption {
      type = types.int;
      default = 16;
    };
  };

  config = mkIf cfg.enable {
    # ghostty is only able to run a executable file. Wrap our command to allow arguments.
    xdg.configFile."ghostty/command.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec tmux new-session -A -s ghostty
      '';
    };

    xdg.configFile."ghostty/config" = {
      text = lib.strings.concatStringsSep "\n" (
        lib.attrsets.mapAttrsToList (name: value: "${name}=${mkValueString value}") (cfg.config // defaultConfig)
      );
    };
  };
}
