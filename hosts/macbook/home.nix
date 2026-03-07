{
  pkgs,
  inputs,
  lib,
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
  home.homeDirectory = lib.mkForce "/Users/matatan";
  home.packages = with pkgs; [
    # ai
    gemini-cli

    # shell
    tmux
    eza
    bat
    fzf
    ripgrep
    fd
    zoxide
    tree
    wget
    ascii-image-converter
    zsh-autosuggestions
    zsh-syntax-highlighting

    age
    sops
    docker
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/Users/matatan/.config/sops/age/keys.txt";
  };

  programs.direnv.enable = true;
  programs.doom-emacs = {
    enable = true;
    doomDir = ../../modules/doom-config;
  };

  # # This symlinks fonts directly into ~/Library/Fonts
  # # making them immediately visible to all Apps
  # home.file."Library/Fonts".source = 
  #   let
  #     # Collect all fonts from your font packages
  #     fontPackages = with pkgs; [
  #       nerd-fonts.fira-code
  #       nerd-fonts.jetbrains-mono
  #       nerd-fonts.iosevka
  #     ];
  #   in
  #   pkgs.symlinkJoin {
  #     name = "user-fonts";
  #     paths = fontPackages;
  #   } + "/share/fonts/truetype"; # Path suffix depends on the package structure
}