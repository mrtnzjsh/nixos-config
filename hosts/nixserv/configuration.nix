{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
    ../../modules/cloudflared.nix
    ../../modules/nextcloud.nix
    ../../modules/media.nix
    ../../modules/nixarr.nix
    ../../modules/couchdb.nix
    ../../modules/authentik.nix
    ../../modules/tailscale.nix
    ../../modules/virtualisation.nix
    ../../modules/zfs.nix
    ../../modules/navidrome.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = ["zfs"];

  networking.hostName = "nixserv";
  networking.hostId = "ca49bafa";

  isServer = true;

  nix.settings = {
    # Fixes the "download buffer is full" warning
    download-buffer-size = 134217728; # 128MB (Double the default)

    experimental-features = ["nix-command" "flakes"];
  };

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

  users.groups = {
    media = {};
  };

  users.users.matatan = {
    isNormalUser = true;
    description = "matatan";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "kvm" "media"];
    packages = with pkgs; [tree];
    shell = pkgs.zsh;
    home = "/home/matatan";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG98QHRQZmFzHXbF8tnsn2DHvKo4ssoq5am0lepWIKND matatan@Joshuas-MBP.localdomain"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSO1I1b4kYhtTaPjbnH7r7TSsnZZvtgq5f61NUleWDj martinez.josh83@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvlqCjyU86h4RLbi6meEpcYlxh/msfwa0M3YashA4iyENa1PszEhvHAwrakHxJKeHoHcja8A7YgKqMuxbXRi0dBnzjoAkdQIJiEP3Bw9zvGWtNKefIBc0Jn21n5c7qbsrOre1Uvi8GHxnj266RBrWwDwARkKZqyS8uH9pa4BwMMKDVovF1+11tJM4UPGH/yQ32EczyBHBDP7PDFVCy4B7gk9W6ITik7NIrywHjGBHKfXXmHL3O10rSPw9YS8oPc7zSLjdSmTUmasL0jXtC4yIw1PHnFWFAmzaVW/g8KgJ6k3D3CEgdXaZv3feBD/uxPoOdzXFjaq/gfi9/sx6stkzeaxqX0LwCTWGyYB820SD4vYYvig/MFKUVQseSlMCXsmw7Oorizzo/xT3bodIegEzB3ABDod6KNvVIybXymd712ZnPeF/ibguVTQVhHv1nPUgNZxftK0mJeWIO7mSG3r9uNBL3Q1qo1/l30jcKUf21KpCFju9NmYpDrQ0jbFJjioCwPxPLsuYGzTnz1K2fDi4ZxbkJq5dmkgXdxBp9m/OH4mRdfQ+NkAaHPW+S1JSs80eWT3h6nB++f+G7AtuCx/2jzJWxnx63si6Lm2fV7lCc6AMxELozFHnT+MjtPNDpOm8Brm2uNHDpJC3167OGS27K3QH5IauvEi1YlQGU4x2diw== matatan@pop-os"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYMPoqVVwPns9wwS6fUNVKLez1eymMw895CorX4EADq8kiDSIVI7IObKhkpijgjHLGbQ3DnM7xQQ9MAb5jGg6MuEOiRHuy2sUwfk0OjfnpPJPE1hVaGxWfdUh9HczrpMZAJXWngTo2CpsB7JUrVAIJ87vsCNXWNU/GOKt6Bn79IgwNu0A/tIrA5Ip6dMjAV68sK7Uv2LGEy0V7gW0apLUvNKFXLvVQVMPeRHj47tOLm/KvMxxMvpZsfGwfrmPXInhurVjjmVyRzjBk8WWCfjW9w5bxGYH7RuweC48owbAoKJKkgx4zQYNZ2UHZo4KxQ2OmD7tQFcAXjdssRJUfnmQ6DVO1s6qPWwFDgN3wWr3KoedcUVj2eAa7LccsXDw+hyLMZ2GLoCku2LtcNOzxCsQXFhkTiep51JjfdaRi/6NyWJ3SrK3hqkaXmuZX5S2Gi3a927TtTWTEb37kV9E4SWosvqT3VCpb/owZDktb8pO1xdX3UXR5xC4ob15x/O/x/2/eRMRgNYAf1rotBL0BGACuENvuiXJbOCOq500nKcJGw/V5vADu/Tuz3HtkxKFzZDdMdslOpfKGrxx3wdYlxJ7GAwIxBzS/nXMajmrVdoRIkTaksqAlEP4hmHHI6QW4wIiFAQuR+FkEE38sdjohZ4qM/eEY3DAQB4DuV/dc3C9wLw== NixOS Desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDP7r0ZvZQc9x2wgRD5WguH5ux6hRb4v57BM44dw4lrl nixtop"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs pkgs;
      # Add the other specific inputs your flake defines
      nvf = inputs.nvf;
      opencode = inputs.opencode;
      nix-doom-emacs = inputs.nix-doom-emacs;
    };

    users.matatan = import ./home.nix;
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/matatan/.config/sops/age/keys.txt";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true; # Allows software to find the .local address
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    mdadm
    zfs
    wireguard-tools
    inputs.pia.packages.${pkgs.system}.default
    xclip
  ];

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443 4533 8123 9000 9090 9091];
    trustedInterfaces = ["tailscale0"];
  };
  networking.bridges = {};
  networking.interfaces = {
    enp2s0f1.useDHCP = false;
    enp2s0f0.useDHCP = true;
    eno2.useDHCP = false;
  };
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Fixes the "Too many open files" error system-wide
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  system.stateVersion = "25.11";
}
