{
  pkgs,
  inputs,
  ...
}: {
  nix.enable = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.users.matatan = import ./home.nix;

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = ["anomalyco/tap"];

    brews = [];
    casks = [
      "1password"
      "alt-tab"
      "antigravity"
      "balenaetcher"
      "docker-desktop"
      "firefox"
      "helium-browser"
      "google-chrome"
      "microsoft-auto-update"
      "nextcloud"
      "private-internet-access"
      "vscodium"
      "wezterm"
      "obsidian"
      "transmission"
      "vlc"
    ];
  };

  environment.systemPackages = [];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "matatan";
  system.stateVersion = 5;
}
