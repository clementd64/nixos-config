{ config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nix.gc = lib.mkIf (!config.boot.isContainer) {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "45min";
    options = "--delete-older-than 30d";
  };

  time.timeZone = "Europe/Paris";
  console = {
    keyMap = "fr";
  };

  boot.tmp.cleanOnBoot = true;

  networking.useDHCP = false;
  systemd.network = {
    enable = lib.mkIf (!config.boot.isContainer) true;
    wait-online.anyInterface = true;
  };

  services.resolved.settings.Resolve = let
    hasIPv4 = lib.any (network:
      let
        networkConfig = network.networkConfig or {};
        dhcp = networkConfig.DHCP or false;
        addresses = networkConfig.Address or [];
      in
        dhcp == true
        || dhcp == "ipv4"
        || lib.any pkgs.net.isIPv4 addresses
    ) (builtins.attrValues config.systemd.network.networks);
  in lib.mkIf (!config.clement.profile.as212625.enable) {
    DNS = if hasIPv4 then
      "2a0c:b641:2b0::1#dns.as212625.net 62.3.50.46#dns.as212625.net"
    else
      "2a0c:b641:2b0::64:0:53#dns64.as212625.net";
    DNSOverTLS = true;
    FallbackDNS = "2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google 8.8.8.8#dns.google 8.8.4.4#dns.google";
  };

  programs.fish = {
    enable = true;
    loginShellInit = ''
      set -g fish_greeting
    '';
  };
  environment.shells = with pkgs; [ fish ];

  users.mutableUsers = false;
  users.users.clement = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  security.polkit.extraConfig = lib.mkIf config.security.polkit.enable ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  programs.command-not-found.enable = false;
  environment.defaultPackages = lib.mkForce [];

  environment.systemPackages =  [ pkgs.htop ];
}
