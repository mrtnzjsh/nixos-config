{config, ...}: {
  sops.secrets.couchdb_pass = {
    key = "couchdb_pass";
  };

  services.couchdb = {
    enable = true;
    adminUser = "admin";
    adminPass = config.sops.secrets.couchdb_pass.path;
    bindAddress = "0.0.0.0"; # Keep it internal, Nginx will expose it
    port = 5984;

    extraConfig = {
      httpd = {
        enable_cors = "true"; # Note: Values often need to be strings "true"
      };
      cors = {
        origins = "app://obsidian.md, obsidian://obsidian.md, *";
        credentials = "true";
        methods = "GET, PUT, POST, HEAD, DELETE";
        headers = "accept, authorization, content-type, origin, referer";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [5984];
}
