{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
    inputs.nix-doom-emacs.homeModule
    ../../modules/shell.nix
    ../../modules/git.nix
    ../../modules/nvf-config.nix
    ../../modules/wezterm.nix
    ../../modules/opencode.nix
  ];

  home.stateVersion = "24.11";
  home.username = "matatan";
  home.homeDirectory = "/home/matatan";
  home.packages = with pkgs; [
    # ai
    gemini-cli

    # shell
    tmux
    eza
    bat
    fzf
    ripgrep
    zoxide
    wl-clipboard
    fastfetch
    starship

    age
    wezterm
    firefox
    google-chrome
    home-manager
    tree-sitter-bin
    ascii-image-converter
    libreoffice
    sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/matatan/.config/sops/age/keys.txt";
  };

  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.doom-emacs = {
    enable = true;
    doomDir = ../../modules/doom-config;
  };
}
