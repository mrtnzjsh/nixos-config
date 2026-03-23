{
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    containers.enable = true;
    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
      onBoot = "start";
      dbus.enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
      };
    };
    podman.enable = true;
  };

  systemd.services.libvrtd.serviceConfig.timeoutStopSec = "30s";

  # UI to manage VMs
  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = true;
    plugins = [pkgs.cockpit-machines];
    settings = {
      WebService = {
        AllowUnencrypted = true;
        Origins = lib.mkForce "http://nixserv:9090 https://nixserv:9090 http://nixserv.local:9090 https://nixserv.local:9090 http://127.0.0.1:9090 https://127.0.0.1:9090 http://10.0.0.173:9090 https://10.0.0.173:9090";
        ProtocolHeader = "X-Forwarded-Proto";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cockpit
    cockpit-machines
    cockpit-files
    cockpit-podman
    virt-manager
    libvirt-dbus
  ];
}
