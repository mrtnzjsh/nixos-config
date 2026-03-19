{config, ...}: {
  sops.secrets.couchdb_pass = {
    key = "couchdb_pass";
  };

  services.couchdb = {
    enable = true;
    adminUser = "admin";
    adminPass = config.sops.secrets.couchdb_pass.path;
    bindAddress = "127.0.0.1"; # Keep it internal, Nginx will expose it
  };

  # Expose CouchDB via Nginx for your mobile devices
  services.nginx.virtualHosts."couchdb.nixserv.casa" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:5984";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
      '';
    };
  };
}
