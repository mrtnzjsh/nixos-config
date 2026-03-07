{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    secrets."self_hosted/litellm_url" = {};
    secrets."self_hosted/api_key" = {};
    secrets."cloudflare/litellm_client_id" = {};
    secrets."cloudflare/litellm_client_secret" = {};

    templates."opencode-config.json" = {
      path = "${config.home.homeDirectory}/.config/opencode/opencode.jsonc";
      content = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "compaction": {
            "auto": true,
            "prune": true,
            "reserved": 8192,
            "threshold": 0.65
          },
          "model": "litellm/qwen-general",
          "default_agent": "plan",
          "agent": {
            "build": {
              "model": "litellm/glm-47-flash"
            },
            "plan": {
              "model": "litellm/qwen-general"
            }
          },
          "provider": {
            "litellm": {
              "npm": "@ai-sdk/openai-compatible",
              "name": "LiteLLM",
              "options": {
                "apiKey": "${config.sops.placeholder."self_hosted/api_key"}",
                "baseURL": "${config.sops.placeholder."self_hosted/litellm_url"}",
                "headers": {
                  "CF-Access-Client-Id": "${config.sops.placeholder."cloudflare/litellm_client_id"}",
                  "CF-Access-Client-Secret": "${config.sops.placeholder."cloudflare/litellm_client_secret"}"
                },
                "stream": false,
              },
              "models": {
                "glm-47-flash": {
                  "id": "glm-47-flash",
                  "limit": {
                    "context": 65536,
                    "output": 1024
                  }
                },
                "qwen-general": {
                  "id": "qwen-general",
                  "limit": {
                    "context": 49152,
                    "output": 1024
                  }
                }
              }
            }
          },
          "permission": {
            "bash": {
              "rm *": "deny",
              "sudo *": "ask",
              "ls *": "allow"
            },
            "edit": "allow",
            "read": "allow",
            "question": "deny"
          },
          "theme": "opencode",
          "autoupdate": false
        }
      '';
    };
  };

  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postFixup =
        (oldAttrs.postFixup or "")
        + ''
          wrapProgram $out/bin/opencode \
            --prefix LD_LIBRARY_PATH : "${pkgs.stdenv.cc.cc.lib}/lib"
        '';
    });

    agents = ./agents;
    skills = ./skills;
  };
}
