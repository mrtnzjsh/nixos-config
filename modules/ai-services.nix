{
  pkgs,
  pkgs-ai,
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    secrets."hugging_face/token" = {};
  };

  systemd.services.vllm-glm = {
    description = "vLLM - GLM-4.7-Flash";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    # This explicitly adds the lscpu binary to the service environment
    path = with pkgs; [util-linux pciutils coreutils cudaPackages.nccl pkgs-ai.vllm-glm];

    environment = {
      VLLM_USE_V1 = "0";
      CUDA_VISIBLE_DEVICES = "0";
      CUDA_DEVICE_ORDER = "PCI_BUS_ID"; # Fix for mixed 3090/3090 Ti setup
      HF_TOKEN = config.sops.placeholder."hugging_face/token";
      VLLM_NCCL_SO_PATH = "${pkgs.cudaPackages.nccl}/lib/libnccl.so.2";
      VLLM_LOGGING_LEVEL = "DEBUG";
      VLLM_DEBUG_LOG_API_SERVER_REQUEST = "1"; # This prints the incoming JSON from OpenCode
    };

    serviceConfig = {
      ExecStart = ''
        ${pkgs-ai.vllm-glm}/bin/vllm serve QuantTrio/GLM-4.7-Flash-AWQ \
          --host 0.0.0.0 --port 8000 \
          --tensor-parallel-size 1 \
          --swap-space 4 \
          --distributed-executor-backend uni \
            --max-model-len 24000 \
            --gpu-memory-utilization 0.9 \
            --enable-expert-parallel \
            --enable-auto-tool-choice \
            --tool-call-parser glm47 \
            --reasoning-parser glm45 \
            --speculative-config.method mtp \
            --speculative-config.num_speculative_tokens 1 \
            --trust-remote-code \
            --enable-prefix-caching \
            --enable-chunked-prefill \
            --max-num-batched-tokens 8192 \
            --disable-log-requests \
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

  systemd.services.vllm-qwen = {
    description = "vLLM - Qwen2.5 14B Instruct";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    # This explicitly adds the lscpu binary to the service environment
    path = with pkgs; [util-linux pciutils coreutils cudaPackages.nccl pkgs-ai.vllm-glm];

    environment = {
      VLLM_USE_V1 = "0";
      CUDA_VISIBLE_DEVICES = "1";
      CUDA_DEVICE_ORDER = "PCI_BUS_ID"; # Fix for mixed 3090/3090 Ti setup
      HF_TOKEN = config.sops.placeholder."hugging_face/token";
      VLLM_NCCL_SO_PATH = "${pkgs.cudaPackages.nccl}/lib/libnccl.so.2";
      VLLM_LOGGING_LEVEL = "DEBUG";
      VLLM_DEBUG_LOG_API_SERVER_REQUEST = "1"; # This prints the incoming JSON from OpenCode
      VLLM_ALLOW_LONG_MAX_MODEL_LEN = "1";
    };

    serviceConfig = {
      ExecStart = ''
        ${pkgs-ai.vllm-glm}/bin/vllm serve Qwen/Qwen2.5-Coder-14B-Instruct-AWQ \
          --host 0.0.0.0 --port 8001 \
          --tensor-parallel-size 1 \
          --max-model-len 49152 \
          --gpu-memory-utilization 0.90 \
          --enable-auto-tool-choice \
          --tool-call-parser hermes \
          --enable-prefix-caching \
          --trust-remote-code \
          --distributed-executor-backend uni \
          --served-model-name qwen-general
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

    systemd.services.litellm = {
      description = "LiteLLM Proxy";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "vllm-glm.service" "vllm-qwen.service"];
      environment = {
        LITELLM_LOG = "DEBUG";
      };
      script = let
        litellm-with-proxy = pkgs.python311.withPackages (ps: [ps.litellm] ++ ps.litellm.optional-dependencies.proxy or []);

        # Unified configuration for routing to the two vLLM instances
        proxyConfig = pkgs.writeText "litellm-config.yaml" ''
          model_list:
            - model_name: glm-47-flash
              litellm_params:
                model: hosted_vllm/glm-47-flash
                api_base: "http://127.0.0.1:8000/v1"
                api_key: "e8a282eb-7b07-42a8-ba62-9e713d730405"
            - model_name: qwen-general
              litellm_params:
                model: hosted_vllm/qwen-general
                api_base: "http://127.0.0.1:8001/v1"
                api_key: "e8a282eb-7b07-42a8-ba62-9e713d730405"

        '';
      in "${litellm-with-proxy}/bin/litellm --config ${proxyConfig} --port 4000";

      serviceConfig = {
        Restart = "always";
        User = "matatan";
      };
    };
  };
}
