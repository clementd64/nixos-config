{ config, lib, pkgs, ... }:

let cfg = config.clement.ssh-agent;
in with lib; {
  options.clement.ssh-agent = {
    enable = mkEnableOption "Enable ssh-agent";
  };

  config = mkIf cfg.enable {
    # Waiting backport https://github.com/nix-community/home-manager/pull/4178
    # services.ssh-agent.enable = true;

    home.sessionVariablesExtra = ''
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
      fi
    '';

    systemd.user.services.ssh-agent = {
      Install.WantedBy = [ "default.target" ];

      Unit = {
        Description = "SSH authentication agent";
        Documentation = "man:ssh-agent(1)";
      };

      Service = {
        ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
      };
    };
  };
}