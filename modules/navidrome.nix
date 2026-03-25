{
  pkgs,
  lib,
  ...
}: {
  services.navidrome = {
    enable = true;
    openFirewall = true;
    package = pkgs.navidrome;
    settings = {
      MusicFolder = "/var/lib/navidrome/music";
      Address = "0.0.0.0";
      Port = 4533;
    };
  };
  users.users.navidrome.extraGroups = ["media"];

  systemd.services.navidrome.serviceConfig = {
    ReadWritePaths = ["/var/lib/navidrome"];
    BindReadOnlyPaths = ["/Sancocho/Fiesta/music"];
  };

  fileSystems."/var/lib/navidrome/music" = {
    device = "/Sancocho/Fiesta/music";
    fsType = "none";
    options = ["bind" "ro"];
  };
}
