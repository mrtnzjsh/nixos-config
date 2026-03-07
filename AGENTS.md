# Agent Instructions for NixOS & Nix-Darwin Configuration

This file provides operating guidelines and codebase context for AI coding agents operating within this repository. 
It acts as the system prompt for tools like OpenCode and other automated engineering assistants.

## 1. Project Overview
This repository contains a unified, declarative system configuration managed using Nix flakes, Home Manager, and nix-darwin. 
The system manages multiple hosts across different architectures (`x86_64-linux` for NixOS and `aarch64-darwin` for macOS).
It heavily features custom configurations for AI workloads, developer tooling (Neovim, Emacs), and secure secret management.

## 2. Build, Lint, and Test Commands

### 2.1 Building and Deploying
Depending on the host you are modifying, use the following commands to build and apply the configuration.

**For NixOS (e.g., `nixos`, `nixtop`):**
```bash
# Apply the configuration to the local NixOS machine directly
sudo nixos-rebuild switch --flake .#nixos

# Build the configuration without applying (dry run / test build) to verify compilation
nixos-rebuild build --flake .#nixos

# Build a VM to test the configuration safely without altering the host system
# This is highly recommended for major system-level changes.
nixos-rebuild build-vm --flake .#nixos
```

**For macOS (nix-darwin) (`matatan-mbp`):**
```bash
# Apply the configuration to the macOS system
nix run nix-darwin -- switch --flake .#matatan-mbp

# Build without applying to check for evaluation or derivation errors
nix build .#darwinConfigurations.matatan-mbp.system
```

### 2.2 Testing
This repository is primarily a declarative configuration flake rather than a software package with traditional unit tests.
Therefore, "testing" primarily involves evaluating the flake and building system closures.

**General Flake Checks:**
```bash
# Evaluate and verify the flake structure, checking for basic syntax errors and broken links
nix flake check
```

**Testing Specific Modules (Single Test Equivalent):**
If you add or modify a specific module or package, the best way to "test" it individually is to evaluate it via `nix eval` or build its specific system derivation:
```bash
# Evaluate a specific configuration attribute to ensure it parses correctly
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.outPath

# Test building a specific package (e.g. if you modified the vllm-glm overlay)
nix build .#packages.x86_64-linux.vllm-glm
```

### 2.3 Linting and Formatting
The codebase strictly adheres to the `alejandra` formatter. It is critical that all Nix code generated or modified is formatted properly.

```bash
# Format all Nix files in the repository
nix run nixpkgs#alejandra -- .

# Check formatting without modifying files (useful for CI/linting)
nix run nixpkgs#alejandra -- --check .
```
Dead code and stylistic linting should be verified before any commits using `deadnix` and `statix`:
```bash
# Find dead/unused code
nix run nixpkgs#deadnix -- .

# Lint for anti-patterns and suggest idiomatic Nix alternatives
nix run nixpkgs#statix -- check .
```

## 3. Code Style Guidelines

### 3.1 Formatting
- **Formatter:** ALWAYS format Nix files using `alejandra`.
- **Indentation:** 2 spaces (managed by Alejandra).
- **Line Length:** Let Alejandra handle the wrapping. Focus on logical structuring.
- **Strings:** Prefer multi-line strings (`''''`) for configuration blocks (e.g., in `nvf-config.nix` or shell scripts) to avoid excessive escaping.

### 3.2 Naming Conventions
- **Files and Directories:** Use `kebab-case` for file names (e.g., `ai-overlays.nix`, `nvf-config.nix`).
- **Nix Variables and Attributes:** Use `camelCase` for internal variables and attribute sets (e.g., `darwinConfigurations`, `specialArgs`).
- **Hostnames:** Use lowercase, descriptive names (`nixos`, `nixtop`, `matatan-mbp`).
- **Secrets:** Sops secret paths should be logically grouped using descriptive paths (e.g., `cloudflare/litellm_client_id`).

### 3.3 Imports and Structure
- **Flake Inputs:** Keep `flake.nix` clean. All inputs should be defined clearly at the top. Use `follows` to minimize duplicated inputs where possible (e.g., `inputs.nixpkgs.follows = "nixpkgs";`).
- **Modularity:** Do not bloat `configuration.nix` or `home.nix`. 
  - Host-specific hardware and boot configurations go in `hosts/<hostname>/`.
  - Shared configurations, applications, and tool setups go in `modules/` (e.g., `modules/wezterm.nix`, `modules/git.nix`).
- **Overlays:** Place complex package overrides in `overlays/` or host-specific overlay files (`hosts/nixos/ai-overlays.nix`).

### 3.4 Types and Configuration
- **NixOS Options:** When defining new custom modules, use the standard NixOS module system (`lib.mkOption`, `lib.types.*`).
- **Type Safety:** Use strict types for options (`types.str`, `types.listOf types.package`, etc.) to fail fast during evaluation. Provide descriptions for all new options.
- **Home Manager:** Keep user-specific dotfiles and CLI tool configurations managed under Home Manager within the respective `home.nix` or shared modules.

### 3.5 Error Handling and Best Practices
- **Evaluation Errors:** Use `assert` statements if certain configuration combinations are invalid.
- **Conditional Configuration:** Use `lib.mkIf`, `lib.mkMerge`, and `lib.mkForce` carefully. Prefer `lib.mkDefault` for baseline settings so they can be overridden easily downstream.
- **Secrets Management:** NEVER hardcode secrets in plain text. Always use `sops-nix`. Secrets must be referenced via `config.sops.secrets."<secret_path>"`.

## 4. Operational Guidelines for Agents
- **Review Existing Code First:** Before adding a new tool or configuration, check if a module already exists in `modules/` or if an overlay is present.
- **Verify Post-Modification:** ALWAYS run `nix flake check` and `nix run nixpkgs#alejandra -- --check .` after modifying Nix files to ensure syntax and formatting are pristine.
- **Package Existence:** If adding a command to a shell script or configuration, ensure the package providing that command is explicitly included in the environment (`environment.systemPackages` or `home.packages`).
- **Security Posture:** Ensure that any newly exposed network services (like Open-WebUI) are appropriately tunnelled (e.g., using the existing `cloudflared` module) or otherwise secured. Do not expose unauthenticated ports globally.

## 5. Notes on Specific Subsystems
- **AI Tooling (`nixos` host):** The `nixos` host has a specialized AI environment. Note the Python dependency overrides (e.g., `compressed-tensors`, `rapidocr-onnxruntime`) in `flake.nix`. Exercise extreme caution when updating `nixpkgs` inputs to ensure these fragile AI tools do not break.
- **OpenCode Ecosystem:** Agent definitions are located in `modules/agents/` and skill definitions in `modules/skills/`. Do not modify these unless explicitly instructed to alter the agent's behavior.
- **Editor Configurations:** Neovim is configured via the `nvf` flake (`modules/nvf-*`), and Doom Emacs is managed declaratively via `nix-doom-emacs`. Respect these domain-specific abstractions.
