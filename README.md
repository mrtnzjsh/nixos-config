# NixOS & Nix-Darwin Configuration Flake

This repository contains the declarative configuration for my machines using
[Nix Flakes](https://nixos.wiki/wiki/Flakes),
[Home Manager](https://github.com/nix-community/home-manager), and
[nix-darwin](https://github.com/LnL7/nix-darwin).

## 🖥️ Hosts

This flake currently manages the following systems:

- **`nixos`** (`x86_64-linux`): A NixOS server focused on AI workloads. It
  features NVIDIA/CUDA support, `vLLM` (vllm-glm), `Open-WebUI`, and
  `Cloudflared` for secure tunneling.
- **`nixtop`** (`x86_64-linux`): A standard NixOS system.
- **`matatan-mbp`** (`aarch64-darwin`): A macOS system managed via `nix-darwin`
  and `nix-homebrew`. It automates the installation of various Homebrew casks
  (like 1Password, Docker, WezTerm, VS Codium, Obsidian, etc.) and integrates
  TouchID with `sudo`.

## ✨ Features

- **Centralized Management:** Uses a single `flake.nix` entrypoint for macOS and
  NixOS systems.
- **Home Manager:** Declarative user environments for the `matatan` user across
  all systems.
- **AI Tooling & Agents:** Dedicated overlays and modules for AI services,
  including custom AI agents (like the _OpenCode Senior Engineer_) and skill
  creators defined in the `modules/agents` and `modules/skills` directories.
- **Secret Management:** Integrated with `sops-nix` using Age keys for secure
  secret deployment.
- **Custom Modules & Overlays:**
  - `nvf`: Neovim flake configuration.
  - `nix-doom-emacs`: Declarative Doom Emacs setup.
  - Fixes for Python packages (like `rapidocr-onnxruntime` and
    `compressed-tensors`) on `nixos-unstable`.

## 🚀 Getting Started

### Prerequisites

Ensure you have Nix installed with Flakes enabled.

### NixOS Deployment

To deploy the configuration to a NixOS machine (e.g., `nixos`):

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### macOS Deployment (nix-darwin)

To deploy the configuration to the macOS machine (`matatan-mbp`):

```bash
nix run nix-darwin -- switch --flake .#matatan-mbp
```

## 📂 Repository Structure

- `flake.nix`: The core flake configuration and dependency inputs.
- `hosts/`: Host-specific configurations (hardware, boot, networking).
  - `nixos/`: Desktop/Server AI machine.
  - `nixtop/`: Secondary NixOS machine.
  - `macbook/`: MacBook (nix-darwin) configuration.
- `modules/`: Shared NixOS/Home-Manager modules (AI services, Cloudflared, Git,
  WezTerm, etc.).
- `overlays/`: Custom nixpkgs overlays (e.g., tree-sitter).
- `secrets/`: SOPS-encrypted secrets (`secrets.yaml`).
