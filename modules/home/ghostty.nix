{ config, lib, pkgs, ... }:

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
    "theme" = "GitHub Dark";

    "command" = "${config.xdg.configHome}/ghostty/command.sh";

    "window-decoration" = false;
    "window-padding-balance" = true;

    # Disable automatic shell integration, as it does not work with tmux
    "shell-integration" = "none";

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

    enableBashIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Bash integration.
      '';
    };

    enableZshIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Zsh integration.
      '';
    };

    enableFishIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Fish integration.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];

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

    programs.bash.initExtra = mkIf cfg.enableBashIntegration (
      mkBefore ''
        if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
            builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
        fi
      '');

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration (
      mkBefore ''
        if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
            builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
        fi
      '');

    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration (
      mkBefore ''
        if test -n "$GHOSTTY_RESOURCES_DIR"
          builtin source "''$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        end
      '');
  };
}
