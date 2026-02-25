{...}: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
    };
  };
  programs.git = {
    enable = true;

    settings = {
      user.email = "mrtnz.jnmn@gmail.com";
      user.name = "Josh Martinez";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim"; # Points to your nvf setup!

      alias = {
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };

    # Ignore annoying OS-specific files globally
    ignores = [".DS_Store" "*.swp" "dist/" "node_modules/"];
  };
}
