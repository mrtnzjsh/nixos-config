{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      update = "pushd ~/nixos-config/ >/dev/null && git add -A && sudo nixos-rebuild switch --flake $HOME/nixos-config#$(hostname) && popd >/dev/null";
      nix-check = "nix flake check ~/nixos-config";
      g = "git";
      v = "nvim";
      conf = "cd $HOME/nixos-config/ && nvim .";
      ls = "eza --icons";
      ll = "eza -l --icons";
      cat = "bat";
      pbcopy = "wl-copy";
    };

    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
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
    options = [ "--cmd cd" ];
  };
}
