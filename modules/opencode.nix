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
              "model": "litellm/glm-47-flash"
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
                "stream": true,
              },
              "models": {
                "glm-47-flash": {
                  "id": "glm-47-flash",
                  "limit": {
                    "context": 131072,
                    "output": 8192
                  }
                }
              }
            }
          },
          "permission": {
            "bash": {
              "rm *": "deny",
              "sudo *": "ask",
              "ls *": "allow",
              "git diff *": "allow"
            },
            "edit": "ask",
            "read": "allow",
            "question": "deny"
          },
          "theme": "opencode",
          "autoupdate": false
        }
      '';
    };
  };

  home.file.".config/opencode/AGENTS.md" = {
    source = ./opencode/opencode-global-AGENTS.md;
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

    # agents = ./opencode/agents;
    skills = ./opencode/skills;
  };
}
