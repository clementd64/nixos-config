{ config, lib, pkgs, ... }:

let
  cfg = config.clement.helix;
  tomlFormat = pkgs.formats.toml { };

  settings = {
    theme = "github_dark";

    editor = {
      line-number = "relative";
      mouse = false;

      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
    };
  };
in with lib; {
  options.clement.helix = {
    enable = mkEnableOption "helix";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.helix ];

    xdg.configFile."helix/config.toml".source = tomlFormat.generate "helix-config" settings;
  };
}
