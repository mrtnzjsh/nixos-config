{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    secrets."pia/username" = {};
    secrets."pia/password" = {};
  };

  services.pia = {
    enable = true;

    credentials = {
      username = config.sops.placeholder."pia/username";
      password = config.sops.placeholder."pia/password";
    };

    protocol = "wireguard";
  };

  # environment.sessionVariables = {
  #   PIA_USER = config.sops.placeholder.pia_username;
  #   PIA_PASS = config.sops.placeholder.pia_password;
  # };
}
