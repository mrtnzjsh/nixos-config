{
  pkgs,
  pkgs-ai,
  config,
  ...
}: {
  systemd.services.vllm-glm = {
    description = "vLLM - GLM-4.7-Flash";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    # This explicitly adds the lscpu binary to the service environment
    path = with pkgs; [util-linux pciutils coreutils cudaPackages.nccl pkgs-ai.vllm-glm];

    serviceConfig = {
      EnvironmentFile = config.sops.secrets.HF_TOKEN.path;
      Environment = [
        "VLLM_USE_V1=0"
        "CUDA_VISIBLE_DEVICES=0,1"
        "CUDA_DEVICE_ORDER=PCI_BUS_ID"
        "VLLM_NCCL_SO_PATH=${pkgs.cudaPackages.nccl}/lib/libnccl.so.2"
        "VLLM_LOGGING_LEVEL=INFO"
        "VLLM_DEBUG_LOG_API_SERVER_REQUEST=1"
        "PYTORCH_ALLOC_CONF=expandable_segments:True"
      ];
      ExecStart = ''
        ${pkgs-ai.vllm-glm}/bin/vllm serve QuantTrio/GLM-4.7-Flash-AWQ \
          --host 0.0.0.0 --port 8000 \
          --tensor-parallel-size 2 \
          --max-model-len 131072 \
          --gpu-memory-utilization 0.90 \
          --enforce-eager \
          --disable-custom-all-reduce \
          --trust-remote-code \
          --kv-cache-dtype auto \
          --enable-auto-tool-choice \
          --tool-call-parser glm47 \
          --reasoning-parser glm45 \
          --enable-prefix-caching \
          --enable-chunked-prefill \
          --served-model-name glm-47-flash
      '';

      # Mandatory for hardware access in a systemd sandbox
      DeviceAllow = [
        "/dev/nvidiactl"
        "/dev/nvidia0"
        "/dev/nvidia1"
        "/dev/nvidia-modeset"
        "/dev/nvidia-uvm"
      ];
      PrivateDevices = false;
      Restart = "always";
      User = "matatan";
    };
  };

  systemd.services.litellm = {
    description = "LiteLLM Proxy";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "vllm-glm.service"];
    environment = {
      LITELLM_LOG = "INFO";
    };
    script = let
      litellm-with-proxy = pkgs.python312.withPackages (ps: [ps.litellm] ++ ps.litellm.optional-dependencies.proxy or []);

      # Unified configuration for routing to the two vLLM instances
      proxyConfig = pkgs.writeText "litellm-config.yaml" ''
        model_list:
          - model_name: glm-47-flash
            litellm_params:
              model: hosted_vllm/glm-47-flash
              api_base: "http://127.0.0.1:8000/v1"
              api_key: "e8a282eb-7b07-42a8-ba62-9e713d730405"
      '';
    in "${litellm-with-proxy}/bin/litellm --config ${proxyConfig} --port 4000";

    serviceConfig = {
      Restart = "always";
      User = "matatan";
    };
  };
}
