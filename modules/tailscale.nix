{
  config,
  pkgs,
  ...
}: let
  tailscaleArgs =
    if config.isServer
    then "--advertise-tags=tag:server --advertise-exit-node"
    else "--advertise-tags=tag:user-machine --advertise-exit-node=false";

  tailscale_secret =
    if config.isServer
    then config.sops.secrets.tailscale_server_key.path
    else config.sops.secrets.tailscale_user_machine_key.path;
in {
  sops.secrets.tailscale_server_key = {
    key = "tailscale_server_key";
  };

  sops.secrets.tailscale_user_machine_key = {
    key = "tailscale_user_machine_key";
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = ["network-online.target" "tailscale.service"];
    wants = ["network-online.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = ''
      # Wait for tailscaled to be ready
      until ${pkgs.tailscale}/bin/tailscale status --json >/dev/null 2>&1; do
        sleep 1
      done
      ${pkgs.tailscale}/bin/tailscale up --authkey $(cat ${tailscale_secret}) ${tailscaleArgs}
    '';
  };

  networking.firewall.checkReversePath = "loose";
}
