{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Specifically for ai tooling that needs newest commit
    nixpkgs-ai.url = "github:nixos/nixpkgs/master";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    authentik-nix.url = "github:nix-community/authentik-nix";
    nixarr.url = "github:nix-media-server/nixarr";
    helium = {
      type = "github";
      owner = "mrtnzjsh";
      repo = "nur-packages";
      ref = "feat/flake-support";
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

    pia = {
      url = "github:mrehanabbasi/pia.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    authentik-nix,
    nixarr,
    helium,
    nixos-hardware,
    home-manager,
    nix-doom-emacs,
    nvf,
    opencode,
    sops-nix,
    pia,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Pkgs for standard desktop hosts
    pkgs-desktop = import nixpkgs {
      localSystem = system;
      overlays = [(import ./overlays/tree-sitter.nix)];
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "google-chrome"
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
            "nvidia-x11"
            "nvidia-settings"
            "1password"
            "obsidian"
          ];
      };
    };

    # Pkgs for the AI-focused 'nixos' host
    pkgs-nixos = import nixpkgs {
      localSystem = system;
      overlays = [
        (import ./overlays/tree-sitter.nix)
        (import ./hosts/nixos/ai-overlays.nix)
      ];
      config = {
        allowUnfree = true;
        allowBroken = true;
        cudaSupport = true;
        allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "google-chrome"
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
            "1password"
            "nvidia-x11"
            "nvidia-settings"
            "open-webui"
            "cudnn"
            "nccl"
          ]
          || (
            nixpkgs.lib.hasPrefix "cuda" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libcusparse" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libcublas" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libcufft" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libcurand" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libcusolver" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libnvjitlink" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libnpp" (nixpkgs.lib.getName pkg)
            || nixpkgs.lib.hasPrefix "libcufile" (nixpkgs.lib.getName pkg)
          );
      };
    };

    pkgs-nixserv = import nixpkgs {
      localSystem = system;
      overlays = [(import ./overlays/tree-sitter.nix)];
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "plexmediaserver"
          ];
      };
    };

    pkgs-ai = import nixpkgs-ai {
      localSystem = system;
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
          {nixpkgs.pkgs = pkgs-desktop;}
          pia.nixosModules.default
          ./hosts/nixtop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs opencode nvf nix-doom-emacs;
              pkgs = pkgs-desktop;
            };
          }

          {
            nix.settings = {
              trusted-users = ["root" "matatan"];
            };
          }
        ];
      };

      nixdesk = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};

        modules = [
          {nixpkgs.pkgs = pkgs-desktop;}
          ./hosts/nixdesk/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs opencode nvf nix-doom-emacs;
              pkgs = pkgs-desktop;
            };
          }

          {
            nix.settings = {
              trusted-users = ["root" "matatan"];
            };
          }
        ];
      };

      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs pkgs-ai;};
        modules = [
          {nixpkgs.pkgs = pkgs-nixos;}
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager

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
          }
        ];
      };

      nixserv = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};

        modules = [
          {nixpkgs.pkgs = pkgs-nixserv;}
          ./hosts/nixserv/configuration.nix
          nixarr.nixosModules.default
          authentik-nix.nixosModules.default
          pia.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            nix.settings = {
              trusted-users = ["root" "matatan"];
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      matatan-mbp = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};

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
