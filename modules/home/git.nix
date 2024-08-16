{ config, lib, ... }:

let cfg = config.clement.git;
in with lib; {
  options.clement.git = {
    enable = mkEnableOption "Enable git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      delta = {
        enable = false; # TODO: 0.17 currently broken
        options = {
          navigate = true;
          side-by-side = true;
        };
      };

      extraConfig = {
        user = {
          email = "clement@dubreuil.dev";
          name = "Clément Dubreuil";
        };

        init = {
          defaultBranch = "main";
        };

        merge = {
          conflictstyle = "diff3";
        };

        diff = {
          colorMoved = "default";
        };

        rerere = {
          enabled = true;
        };
      };

      ignores = [
        ".envrc"
        ".direnv"
        ".vscode"
        ".venv"
      ];
    };
  };
}
