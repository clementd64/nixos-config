{
  system = [
    profiles/as212625
    profiles/baseline.nix
    profiles/container.nix
    profiles/mesh.nix
    profiles/router
    profiles/server.nix
    system/compose.nix
    system/container.nix
    system/docker.nix
    system/dummy.nix
    system/factorio.nix
    system/firewall.nix
    system/http2https.nix
    system/ipset.nix
    system/kubelet.nix
    system/local/network.nix
    system/nat64.nix
    system/oci.nix
    system/secrets.nix
    system/ssh.nix
    system/systemd-socket.nix
    system/traefik.nix
    system/wireguard.nix
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
    home/tmux
    home/tools.nix
    home/vscode.nix
  ];

  disk = {
    mira = import disk/mira.nix;
  };
}
