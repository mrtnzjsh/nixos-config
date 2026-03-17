{
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixdesk";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  services.blueman.enable = true;
  services.printing.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Cosmic
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "matatan";
  };
  services.system76-scheduler.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;
  services.hardware.bolt.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    wireplumber.extraConfig."10-default-sink.conf" = {
      "wireplumber.settings" = {
        "default-nodes" = {
          "audio" = {
            "output" = "alsa_output.pci-0000_0a_00.1.hdi-stereo";
          };
        };
      };
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.matatan = import ./home.nix;

  users.users.matatan = {
    isNormalUser = true;
    extraGroups = ["wheel" "audio"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  environment.systemPackages = with pkgs; [
    vim

    # System
    wget
    pavucontrol
    alsa-utils
    pulseaudio

    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium
    steam
  ];

  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  environment.shells = [pkgs.zsh];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  programs.steam.enable = true;

  # Hyprland config for when i want to use it
  # programs.hyprland = {
  #   enable = true;
  #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  #   withUWSM = true;
  #   xwayland.enable = true;
  # };
  # services.displayManager.enable = true;
  # services.displayManager.gdm.enable = true;
  # services.displayManager.gdm.wayland = true;

  system.stateVersion = "25.05";
}
