{ config, lib, ... }:

let cfg = config.clement.neovim;
in with lib; {
  options.clement.neovim = {
    enable = mkEnableOption "Enable neovim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # TODO: manage plugin via home-manager

    programs.neovim = {
      enable = true;
      extraConfig = concatStringsSep "\n"
        (map
          (file: builtins.readFile ./${file})
          (filter (file: hasSuffix ".vim" file) (builtins.attrNames (builtins.readDir ./.)))
        );
    };
  };
}
