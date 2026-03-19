{lib, ...}: {
  users.groups.mediacenter = {
    gid = 999;
  };

  users.users.plex = {
    isSystemUser = true;
    group = lib.mkForce "plex";
    extraGroups = ["mediacenter"];
  };

  users.groups.plex = {};
  users.users.matatan.extraGroups = ["mediacenter"];

  systemd.tmpfiles.rules = [
    "d /Sancocho 0755 root root -"
    "d /Sancocho/Fiesta 0755 root mediacenter -"
    "d /Sancocho/Fiesta/movies-tv 0775 plex mediacenter -"

    "Z /Sancocho/Fiesta/movies-tv/movies 0775 plex mediacenter -"
    "Z /Sancocho/Fiesta/movies-tv/tv 0775 plex mediacenter -"

    # 2. The Mount Points (The paths Plex actually looks at)
    "d /data/media/movies 0775 plex mediacenter -"
    "d /data/media/tv 0775 plex mediacenter -"
  ];

  systemd.services.plex.after = ["zfs-mount.service" "local-fs.target"];
}
