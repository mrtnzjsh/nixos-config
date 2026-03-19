{config, ...}: {
  sops.secrets.authentik_env = {
    key = "authentik_env";
  };

  services.authentik = {
    enable = true;
    createDatabase = true;

    environmentFile = config.sops.secrets.authentik_env.path;

    settings = {
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };
}
