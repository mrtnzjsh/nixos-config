{config, ...}: {
  sops.secrets.vpn_conf = {
    key = "vpn_conf";
  };

  nixarr = {
    enable = true;
    mediaDir = "/data/media";
    stateDir = "/var/lib/nixarr";

    vpn = {
      enable = true;
      wgConf = config.sops.secrets.vpn_conf.path;
    };

    plex = {
      enable = true;
      openFirewall = true;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
    };
  };
}
