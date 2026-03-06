{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    secrets."self_hosted/owui_api_key" = {};
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8080; #
    environment = {
      OLLAMA_BASE_URL = "http://localhost:4000";
      OPENWEBUI_API_KEY = "${config.sops.placeholder."self_hosted/owui_api_key"}";
      WEBUI_AUTH = "True";
    };
  };
}
