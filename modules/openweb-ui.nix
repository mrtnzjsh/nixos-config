{config, ...}: {
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    environmentFile = config.sops.secrets.OPENWEBUI_API_KEY.path;
    environment = {
      OLLAMA_BASE_URL = "http://localhost:4000";
      WEBUI_AUTH = "True";
    };
  };
}
