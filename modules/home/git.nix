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
        enable = true;
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
