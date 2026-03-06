{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
    ../../modules/shell.nix
    ../../modules/git.nix
    ../../modules/nvf-config.nix
    ../../modules/opencode.nix
  ];

  home.stateVersion = "24.11";
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

    home-manager
    tree-sitter-bin
    ascii-image-converter
  ];

  programs.zsh.enable = true;
  programs.doom-emacs = {
    enable = true;
    emacsPackage = pkgs.emacs-nox;
    doomDir = ../../modules/doom-config;
  };
}
