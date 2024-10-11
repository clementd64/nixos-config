{
  system = [
    profiles/baseline.nix
    profiles/container.nix
    profiles/k3s.nix
    profiles/router
    profiles/server.nix
    system/container.nix
    system/docker.nix
    system/ipset.nix
    system/k3s.nix
    system/kubelet.nix
    system/local/network.nix
    system/nat64.nix
    system/secrets.nix
    system/ssh.nix
    system/systemd-socket.nix
    system/xserver.nix
  ];

  home = [
    home/alacritty.nix
    home/dunst.nix
    home/fish.nix
    home/ghostty.nix
    home/git.nix
    home/helix.nix
    home/htop.nix
    home/neovim
    home/rofi.nix
    home/starship
    home/tools.nix
    home/vscode.nix
  ];
}
