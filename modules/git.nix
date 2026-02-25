{ pkgs, ... }:

{

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

      alias = {};
    };

    # Ignore annoying OS-specific files globally
    ignores = [ ".DS_Store" "*.swp" "dist/" "node_modules/" ];
  };
}
