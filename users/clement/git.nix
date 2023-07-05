{ ... }:
{
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
}
