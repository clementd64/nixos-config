{
  system = [
    system/bird.nix
    system/common.nix
    system/container.nix
    system/docker.nix
    system/k3s.nix
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
