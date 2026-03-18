{
  pkgs,
  pkgs-ai,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/openweb-ui.nix
    ../../modules/cloudflared.nix
    ../../modules/ai-services.nix
    inputs.sops-nix.nixosModules.sops
  ];

  # Bootloader settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  boot.swraid.mdadmConf = "MAILADDR root";

  networking.hostName = "nixos";
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.download-buffer-size = 524288000;

  time.timeZone = "America/New_York";

  users.users.matatan = {
    isNormalUser = true;
    extraGroups = ["wheel"];
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
      inherit inputs pkgs pkgs-ai;
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
    secrets.HF_TOKEN = {
      key = "hugging_face/token";
      owner = "matatan";
    };
    secrets.OPENWEBUI_API_KEY = {
      key = "self_hosted/owui_api_key";
      owner = "matatan";
    };
  };

  # NVIDIA Graphics Configuration
  boot.kernelModules = ["nvidia_uvm" "nvidia_modeset"];
  boot.kernelParams = [
    "nvidia.NVreg_RestrictProfilingToAdminUsers=0"
    # Force P2P to stay active and avoid power-cycling
    "nvidia-drm.modeset=1"
  ];
  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = false;
    nvidiaSettings = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    mdadm
    ethtool
    oterm
    cudatoolkit
    pkgs-ai.vllm-glm
  ];

  networking.firewall.enable = false;

  system.stateVersion = "24.11";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nix";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };
}
