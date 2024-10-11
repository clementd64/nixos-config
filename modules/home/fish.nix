{ config, lib, pkgs, ... }:

let cfg = config.clement.fish;
in with lib; {
  options.clement.fish = {
    enable = mkEnableOption "Enable fish";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        g = "git";
        gd = "cd (git rev-parse --show-toplevel)";

        d = "docker";
        dc = "docker compose";
        dcd = "docker compose down -t0 -v --remove-orphans";
        docker-compose = "docker compose"; # migrate legacy for cleaner history

        k = "kubectl";
        kctx = "kubectl config use-context";
        kns = "kubectl config set-context --current --namespace";

        tf = "tofu";

        ls = "eza";
        cat = "bat";
        xcp = "xclip -selection clipboard";

        vim = mkIf config.clement.neovim.enable "nvim";
        v = mkIf config.clement.neovim.enable "nvim";

        sudo = "run0";
      };

      functions = {
        fish_greeting = "";
        mkcd = "mkdir -p $argv && cd $argv";
      };

      # TMP(ghostty): add .local/bin to PATH
      shellInit = ''
        fish_add_path $HOME/.local/bin
      '';

      interactiveShellInit = ''
        if string match -q "$TERM_PROGRAM" "vscode"
          function cd
            if count $argv > /dev/null
              builtin cd $argv
            else
              builtin cd (git rev-parse --show-toplevel 2>/dev/null) || builtin cd
            end
          end
        end
      '';
    };

    programs.bat.enable = true;
    programs.direnv.enable = true;
    # programs.exa.enable = true;
    home.packages = with pkgs; [
      eza
    ];

    # Also enable bash for nix-shell
    programs.bash.enable = true;
  };
}
