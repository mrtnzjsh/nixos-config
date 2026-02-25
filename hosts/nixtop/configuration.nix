{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Limit WiFi Power for screen flicker
  boot.extraModprobeConfig = ''
    # Disables aggressive power saving that causes voltage/signal spikes
    options iwlwifi power_save=0
    # Disables specialized power sleep states
    options iwlwifi uapsd_disable=1
    # Forces the MVM (MAC) layer into a high-performance/stable mode
    options iwlmvm power_scheme=1
    # Disables TX aggregation to reduce peak power spikes
    options iwlwifi 11n_disable=8
  '';
  networking.localCommands = ''
    ${pkgs.iw}/bin/iw reg set US
    # Set the Transmit Power limit to 10 dBm (1000 mBm)
    # Lowering further from previous (ineffective) 15 dBm to reduce power contention.
    ${pkgs.iw}/bin/iw dev wlp9s0f0 set txpower limit 250
  '';

  # Intel Graphics fix (often needed alongside the WiFi fix)
  # PSR (Panel Self Refresh) is extremely sensitive to WiFi interference.
  # DC (Display Core) power states can also cause flickering on high-end Lenovo laptops.
  # We force i915 because the newer 'xe' driver often ignores these flags on Meteor Lake.
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.enable_fbc=0"
    "i915.enable_dc=0"
    "i915.enable_ips=0"
    "i915.enable_guc=3"
    "i915.modeset=1"
    "i915.force_probe=*" # Force i915 to claim the GPU instead of 'xe'
    "intel_idle.max_cstate=4"
  ];

  networking.hostName = "nixtop"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
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

  # Fingerprint
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matatan = {
    isNormalUser = true;
    description = "matatan";
    extraGroups = ["networkmanager" "wheel"];
    packages = [];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  environment.shells = [pkgs.zsh];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];

  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "google-chrome"
  #   ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Home Manager
  home-manager.users.matatan = {config, ...}: {
    imports = [
      inputs.nvf.homeManagerModules.default
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
      fd
      zoxide
      wl-clipboard

      wezterm
      firefox
      google-chrome
      home-manager
      tree-sitter-bin
      ascii-image-converter
      libreoffice
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
