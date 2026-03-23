{config, ...}: {
  sops.secrets.services_hub_creds = {
    key = "services_hub_creds";
    restartUnits = ["cloudflared-tunnel-8ccf2f3e-1cbd-4861-8356-383c20bd0a1d.service"];
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "8ccf2f3e-1cbd-4861-8356-383c20bd0a1d" = {
        credentialsFile = config.sops.secrets.services_hub_creds.path;
        default = "http_status:404";
        ingress = {
          "hub.loscuatrogolpes.casa" = "http://localhost:8080";
          "chat.loscuatrogolpes.casa" = "http://10.0.0.173:8080";
          "api-vllm.loscuatrogolpes.casa" = "http://10.0.0.173:4000";
          "auth.loscuatrogolpes.casa" = "http://localhost:9000";
          "ha.loscuatrogolpes.casa" = "http://10.0.0.207:8123";
        };
      };
    };
  };
}
