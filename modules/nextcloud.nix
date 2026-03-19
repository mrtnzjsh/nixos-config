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
    options = ["bind" "rw"];
    noCheck = true;
  };

  # Matatan
  fileSystems."/var/lib/nextcloud/data/matatan/files" = {
    device = "/Sancocho/NextCloudStorage/matatan/files";
    options = ["bind" "rw"];
    noCheck = true;
  };

  # C85Galaxy
  fileSystems."/var/lib/nextcloud/data/c85galaxy/files" = {
    device = "/Sancocho/NextCloudStorage/c85galaxy/files";
    options = ["bind" "rw"];
    noCheck = true;
  };

  # Permissions rule
  systemd.tmpfiles.rules = [
    "d /var/lib/nextcloud/data/admin/files/Sancocho 0750 nextcloud nextcloud -"
  ];
  systemd.services.nextcloud-setup.enable = false;
  # 2. Automation: The "First Boot" Setup Script
  # This script runs once, fixes Postgres, and installs Nextcloud if missing.
  systemd.services.nextcloud-init-automation = {
    description = "Automated Nextcloud Preparation and Install";
    after = ["postgresql.service" "sops-install-secrets.service"];
    before = ["phpfpm-nextcloud.service"];
    wantedBy = ["multi-user.target"];

    script = ''
      # 1. Ensure Postgres Schema permissions (The "Public Schema" fix)
      ${pkgs.postgresql}/bin/psql -U postgres -d nextcloud -c \
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

        # 4. Fix permissions immediately
        echo "Indexing ZFS pool Sancocho..."
        sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan --all
        echo "Indexing Admin Sancocho View..."
        sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan admin

        echo "Indexing Matatan Personal View..."
        sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan matatan
        echo "Indexing C85Galaxy Personal View..."
        sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan c85galaxy

        chown -R nextcloud:nextcloud /var/lib/nextcloud
        rm -f /var/lib/nextcloud/config/CAN_INSTALL
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Needs root to fix Postgres and directory owners
      RemainAfterExit = true;
    };
  };

  # Standard database setup for Nextcloud
  services.postgresql.enable = true;
}
