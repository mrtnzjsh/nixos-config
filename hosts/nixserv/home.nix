{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-doom-emacs.homeModule
    inputs.nvf.homeManagerModules.default
    inputs.sops-nix.homeManagerModules.sops
    ../../modules/shell.nix
    ../../modules/git.nix
    ../../modules/nvf-config.nix
    ../../modules/opencode.nix
  ];

  home.stateVersion = "25.11";
  home.username = "matatan";
  home.homeDirectory = "/home/matatan";
  home.packages = with pkgs; [
    gemini-cli

    # shell
    tmux
    eza
    bat
    fzf
    ripgrep
    fd
    zoxide
    wl-clipboard
    fastfetch

    age
    sops
    home-manager
    tree-sitter-bin
    ascii-image-converter
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/matatan/.config/sops/age/keys.txt";
  };

  programs.zsh.enable = true;
  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs-nox;
    doomDir = ../../modules/doom-config;
  };
}
