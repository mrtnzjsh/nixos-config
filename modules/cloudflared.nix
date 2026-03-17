{config, ...}: {
  sops.secrets.cloudflare_owui_creds = {
    key = "cloudflare_owui_creds";
    restartUnits = ["cloudflared-tunnel-d72bf763-1f5c-4797-bc71-f589fb67ebff.service"];
  };

  sops.secrets.cloudflare_litellm_creds = {
    key = "cloudflare_litellm_creds";
    restartUnits = ["cloudflared-tunnel-37d497eb-3b17-46f1-9313-18131436ab2c.service"];
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "d72bf763-1f5c-4797-bc71-f589fb67ebff" = {
        credentialsFile = config.sops.secrets.cloudflare_owui_creds.path;
        default = "http_status:404";
        ingress = {"ai.loscuatrogolpes.casa" = "http://localhost:8080";}; #
      };
      "37d497eb-3b17-46f1-9313-18131436ab2c" = {
        credentialsFile = config.sops.secrets.cloudflare_litellm_creds.path;
        default = "http_status:404";
        ingress = {"ai-ollama.loscuatrogolpes.casa" = "http://localhost:4000";}; #
      };
    };
  };
}
