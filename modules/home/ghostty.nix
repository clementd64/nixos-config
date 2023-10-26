{ config, lib, ... }:

let cfg = config.clement.ghostty;
in with lib; {
  options.clement.ghostty = {
    enable = mkEnableOption "Enable ghostty";
  };

  config = mkIf cfg.enable {
    # ghostty is current not installed with nix.
    # To install it manually:
    # $ git clone git@github.com:mitchellh/ghostty.git
    # $ cd ghostty
    # $ direnv allow # enter nix shell
    # $ zig build -p $HOME/.local -Doptimize=ReleaseFast
    xdg.configFile."ghostty/command.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec tmux new-session -A -s ghostty
      '';
    };
  };
}