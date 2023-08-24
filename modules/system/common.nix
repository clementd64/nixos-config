{ pkgs, ... }:
{
  time.timeZone = "Europe/Paris";
  console = {
    keyMap = "fr";
  };

  boot.tmp.cleanOnBoot = true;

  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  users.mutableUsers = false;
  users.users.clement = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
    # TODO: find a way to manage secret that is installer friendly
    passwordFile = "/etc/user-password";
  };
  security.sudo.wheelNeedsPassword = false;

  programs.command-not-found.enable = false;
}
