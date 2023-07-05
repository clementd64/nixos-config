{ lib, ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true; # I live in a real country
    escapeTime = 0;
    keyMode = "vi";
    prefix = "C-q";
    terminal = "xterm-256color";

    extraConfig = lib.concatStringsSep "\n"
      (map
        (fileName: builtins.readFile (./tmux + "/${fileName}"))
        (builtins.attrNames (builtins.readDir ./tmux))
      );
  };
}