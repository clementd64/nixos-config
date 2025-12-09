{ config, lib, ... }:

let cfg = config.clement.tmux;
in with lib; {
  options.clement.tmux = {
    enable = mkEnableOption "tmux";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      clock24 = true; # I live in a real country
      escapeTime = 0;
      keyMode = "vi";
      prefix = "C-q";
      terminal = "xterm-256color";

      extraConfig = concatStringsSep "\n"
        (map
          (file: builtins.readFile ./${file})
          (filter (file: hasSuffix ".conf" file) (builtins.attrNames (builtins.readDir ./.)))
        );
    };
  };
}
