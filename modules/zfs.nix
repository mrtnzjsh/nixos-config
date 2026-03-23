{pkgs, ...}: {
  boot.zfs.extraPools = ["Sancocho"];

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nixserv";
        "netbios name" = "nixserv";
        "security" = "user";
        "hosts allow" = "10.0.0. 100.64. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
      };
      ha_backups = {
        path = "/Sancocho/ha-backups";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = "matatan";
        "vfs objects" = "acl_xattr";
        "map acl inherit" = "yes";
      };
    };
  };
}
