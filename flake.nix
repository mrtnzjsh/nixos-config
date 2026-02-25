{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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
    nixos-hardware,
    home-manager,
    nvf,
    opencode,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    # Inside your flake.nix let block
    myOverlay = final: prev: {
      tree-sitter-bin = let
        version = "0.26.1";
      in
        prev.stdenv.mkDerivation {
          inherit version;
          pname = "tree-sitter-bin";

          # Download the pre-compiled linux-x64 binary directly from GitHub
          src = final.fetchurl {
            url = "https://github.com/tree-sitter/tree-sitter/releases/download/v${version}/tree-sitter-linux-x64.gz";
            # You will need to update this hash once Nix tells you the 'got' value
            hash = "sha256-10GC//v0QfJHNxrWr3fZmxCsn3iNfgaOS0SZLZ1tfCY=";
          };

          # Since it's a gzipped binary, we just need to unpack and move it
          nativeBuildInputs = [final.gzip];
          unpackPhase = "gzip -d < $src > tree-sitter";

          installPhase = ''
            mkdir -p $out/bin
            cp tree-sitter $out/bin/
            chmod +x $out/bin/tree-sitter
          '';
        };

      # Temporary overlay for nvim-treesitter to work around breaking changes
      # until the package stabilizes
      vimPlugins =
        prev.vimPlugins
        // {
          nvim-treesitter = prev.vimPlugins.nvim-treesitter-legacy;
        };
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [myOverlay];
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "google-chrome"
          ];
      };
    };
  in {
    nixosConfigurations = {
      nixtop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};

        modules = [
          {nixpkgs.pkgs = pkgs;}
          ./hosts/nixtop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs opencode nvf pkgs;
            };
          }

          {
            nix.settings = {
              trusted-users = ["root" "matatan"];
            };
          }
        ];
      };
    };
  };
}
