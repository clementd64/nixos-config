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

        vim = "nvim";
        v = "nvim";
      };

      functions = {
        fish_greeting = "";
        mkcd = "mkdir -p $argv && cd $argv";
      };
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
