{pkgs, ...}: let
  rebuildCommand =
    if pkgs.stdenv.isLinux
    then "nixos-rebuild"
    else "darwin-rebuild";
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      {
        update = "pushd ~/.nixos-config/ >/dev/null && git add -A && sudo '${rebuildCommand}' switch --flake .#$(hostname -s) && popd >/dev/null";
        nix-check = "nix flake check ~/.nixos-config";
        v = "nvim";
        conf = "cd $HOME/.nixos-config/ && nvim .";
        ls = "eza --icons";
        ll = "eza -l --icons";
        cat = "bat";

        # git
        g = "git";
        gs = "g status";
        ga = "g add";
        gc = "g commit";
        gcm = "gc -m";
        gco = "g checkout";
        gpr = "git pull --rebase";
      }
      // (pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
        # These keys will ONLY exist on Linux. On macOS, they won't be defined at all.
        pbcopy = "wl-copy";
        pbpaste = "wl-paste";
      });

    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      fill = {
        symbol = " ";
      };

      format = builtins.concatStringsSep " " [
        "$directory"
        "$git_branch"
        "$git_status"
        "$fill"
        "$python"
        "$java"
        "$line_break"
        "$character"
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}
