{
  config,
  pkgs,
  ...
}: {
  sops.secrets.nextcloud_admin_pass = {
    key = "nextcloud_admin_pass";
  };

  services.nextcloud = {
    enable = true;
    hostName = "cloud.nixserv.casa";
    configureRedis = true;
    database.createLocally = true;
    package = pkgs.nextcloud33;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud_admin_pass.path;
    };
    settings = {
      trusted_domains = ["nixserv.local"];
    };
  };

  # The Bind Mount (This can live here perfectly fine!)
  # Admin
  fileSystems."/var/lib/nextcloud/data/admin/files/Sancocho" = {
    device = "/Sancocho/NextCloudStorage";
    fsType = "none";
    options = ["bind" "rw"];
    noCheck = true;
  };

  # Matatan
  fileSystems."/var/lib/nextcloud/data/matatan/files" = {
    device = "/Sancocho/NextCloudStorage/matatan/files";
    fsType = "none";
    options = ["bind" "rw"];
    noCheck = true;
  };

  # C85Galaxy
  fileSystems."/var/lib/nextcloud/data/c85galaxy/files" = {
    device = "/Sancocho/NextCloudStorage/c85galaxy/files";
    fsType = "none";
    options = ["bind" "rw"];
    noCheck = true;
  };

  # Permissions rules for both mount points and ZFS sources
  systemd.tmpfiles.rules = [
    "d /Sancocho/NextCloudStorage 0750 nextcloud nextcloud -"
    "d /Sancocho/NextCloudStorage/matatan/files 0750 nextcloud nextcloud -"
    "d /Sancocho/NextCloudStorage/c85galaxy/files 0750 nextcloud nextcloud -"
    "d /var/lib/nextcloud/data/matatan 0750 nextcloud nextcloud -"
    "d /var/lib/nextcloud/data/matatan/files 0750 nextcloud nextcloud -"
    "d /var/lib/nextcloud/data/c85galaxy 0750 nextcloud nextcloud -"
    "d /var/lib/nextcloud/data/c85galaxy/files 0750 nextcloud nextcloud -"
    "d /var/lib/nextcloud/data/admin/files/Sancocho 0750 nextcloud nextcloud -"
    "Z /Sancocho/NextCloudStorage - nextcloud nextcloud -"
  ];

  systemd.services.nextcloud-setup.enable = false;
  # 2. Automation: The "First Boot" Setup Script
  # This script runs once, fixes Postgres, and installs Nextcloud if missing.
  systemd.services.nextcloud-init-automation = {
    description = "Automated Nextcloud Preparation and Install";
    after = ["postgresql.service" "sops-install-secrets.service" "local-fs.target"];
    before = ["phpfpm-nextcloud.service"];
    wantedBy = ["multi-user.target"];

    script = ''
      # 1. Ensure Postgres Schema permissions (The "Public Schema" fix)
      sudo -u postgres ${pkgs.postgresql}/bin/psql -d nextcloud -c \
        "ALTER SCHEMA public OWNER TO nextcloud; GRANT ALL ON SCHEMA public TO nextcloud;" || true

      # 2. Check if Nextcloud is already installed
      if ! [ -f /var/lib/nextcloud/config/config.php ]; then
        echo "Nextcloud not found. Starting automated install..."

        # 3. Perform the Install
        ${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:install \
          --database "pgsql" \
          --database-host "/run/postgresql" \
          --database-name "nextcloud" \
          --database-user "nextcloud" \
          --admin-user "admin" \
          --admin-pass "$(cat ${config.services.nextcloud.config.adminpassFile})" \
          --data-dir "/var/lib/nextcloud/data"

        rm -f /var/lib/nextcloud/config/CAN_INSTALL
      fi

      # 4. Fix permissions every time to ensure ZFS mounts are correct
      echo "Fixing permissions on /var/lib/nextcloud and /Sancocho/NextCloudStorage..."
      chown -R nextcloud:nextcloud /var/lib/nextcloud
      chown -R nextcloud:nextcloud /Sancocho/NextCloudStorage

      echo "Checking for Nextcloud upgrades..."
      sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ upgrade || true

      echo "Indexing files for all users..."
      sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan --all
    '';
    path = [ pkgs.sudo ];
    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Needs root to fix Postgres and directory owners
      RemainAfterExit = true;
    };
  };

  # Standard database setup for Nextcloud
  services.postgresql.enable = true;
}
