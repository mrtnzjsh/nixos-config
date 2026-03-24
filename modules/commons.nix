{lib, ...}: {
  options = {
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Denotes whether the Nix machine is a server";
    };
  };
}
