{
  config,
  pkgs,
  ...
}: {
  sops.secrets.tailscale_key = {
    key = "tailscale_key";
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
      ${pkgs.tailscale}/bin/tailscale up --authkey $(cat ${config.sops.secrets.tailscale_key.path}) \
      --advertise-tags=tag:server \
      --advertise-exit-node
    '';
  };

  networking.firewall.checkReversePath = "loose";
}
