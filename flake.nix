{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Specifically for ai tooling that needs newest commit
    nixpkgs-ai.url = "github:nixos/nixpkgs/master";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    local-helium = {
      url = "path:/home/matatan/Developer/nur-packages";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs.url = "github:marienz/nix-doom-emacs-unstraightened";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode.url = "github:anomalyco/opencode";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-ai,
    nix-darwin,
    nix-homebrew,
    local-helium,
    nixos-hardware,
    home-manager,
    nix-doom-emacs,
    nvf,
    opencode,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [(import ./overlays/tree-sitter.nix)];
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "google-chrome"
          ];
      };
    };

    pkgs-ai = import nixpkgs-ai {
      inherit system;
      overlays = [(import ./hosts/nixos/ai-overlays.nix)];
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    };
  in {
    nixosConfigurations = {
      nixtop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};

        modules = [
          {nixpkgs.pkgs = pkgs;}
          ./hosts/nixtop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs opencode nvf nix-doom-emacs pkgs;
            };
          }

          {
            nix.settings = {
              trusted-users = ["root" "matatan"];
            };
          }
        ];
      };

      packages.${system} = {
        vllm-glm = pkgs-ai.vllm-glm;
        default = pkgs-ai.vllm-glm;
      };

      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs pkgs-ai;};
        modules = [
          ./hosts/nixos/configuration.nix
          inputs.home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = {
              inherit inputs opencode nvf nix-doom-emacs pkgs;
            };
          }

          {
            # 1. Update Binary Cache (Fixes security warnings and "ignoring substitute")
            nix.settings = {
              substituters = [
                "https://cache.nixos-cuda.org"
                "https://cuda-maintainers.cachix.org"
                "https://cache.nixos.org"
              ];
              trusted-public-keys = [
                "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
              # Critical for allowing non-root users to use the cache
              trusted-users = ["root" "matatan"];
            };

            # 2. Overlays to fix broken Python dependencies on nixos-unstable
            nixpkgs.overlays = [
              (final: prev: {
                # Fix for Python 3.12 (RapidOCR test core-dumps)
                python312Packages = prev.python312Packages.override {
                  overrides = pyFinal: pyPrev: {
                    compressed-tensors = pyPrev.compressed-tensors.overrideAttrs (old: {
                      doCheck = false; # Disables pytest to allow the build to complete
                      checkPhase = "true";
                      installCheckPhase = "true";
                      pythonImportsCheck = [];
                    });

                    rapidocr-onnxruntime = pyPrev.rapidocr-onnxruntime.overrideAttrs (old: {
                      doCheck = false;
                    });
                  };
                };
              })
            ];
          }
        ];
      };
    };
    darwinConfigurations = {
      matatan-mbp = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/macbook/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          inputs.home-manager.darwinModules.home-manager
          {
            nix-homebrew = {
              enable = true;
              user = "matatan";
              autoMigrate = true;
            };
          }
        ];
      };
    };
  };
}
