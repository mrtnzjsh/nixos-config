{
  config,
  pkgs,
  ...
}: {
  systemd.services.nvidia-tuning = {
    description = "Apply NVIDIA GPU power caps and persistence mode";
    wantedBy = ["multi-user.target"];
    after = ["nvidia-persistenced.service"];
    path = [ config.boot.kernelPackages.nvidia_x11.bin ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "30";
      ExecStart = pkgs.writeShellScript "nvidia-tuning" ''
        # Persistence mode must be on for power limits to persist
        nvidia-smi -pm 1
        
        while true; do
          nvidia-smi -pl 250
          sleep 3600
        done
      '';
    };
  };
}
