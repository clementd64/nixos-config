{ lib, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # TODO: manage plugin via home-manager

  programs.neovim = {
    enable = true;
    extraConfig = lib.concatStringsSep "\n"
      (map
        (fileName: builtins.readFile (./nvim + "/${fileName}"))
        (builtins.attrNames (builtins.readDir ./nvim))
      );
  };
}
