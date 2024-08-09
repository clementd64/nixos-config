{
  system = [
    profiles/baseline.nix
    profiles/container.nix
    profiles/k3s.nix
    profiles/router
    profiles/server.nix
    system/container.nix
    system/docker.nix
    system/k3s.nix
    system/kubelet.nix
    system/secrets.nix
    system/ssh.nix
    system/unstable.nix
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
