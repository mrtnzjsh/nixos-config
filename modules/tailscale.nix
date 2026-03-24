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
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.tailscale}/bin/tailscale up --authkey $(cat ${tailscale_secret}) ${tailscaleArgs}
    '';
  };

  networking.firewall.checkReversePath = "loose";
}
