{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.git = {
    enable = true;
    # Installs git-lfs and its filter config; a bare filter.lfs section
    # with required = true fails every checkout of an LFS repo.
    lfs.enable = true;

    ignores = [ ];

    settings = {
      user = {
        name = "Hirokazu Hata";
        email = "h.hata.ai.t@gmail.com";
      };
      # A relative include.path resolves against the file containing it
      # (~/.config/git/config), so spell out the home directory.
      include = {
        path = "~/.gitconfig.local";
      };
      core = {
        excludesFile = "~/.config/git/ignore";
        editor = "nvim";
      };
      push = {
        default = "current";
      };
      branch = {
        autosetuprebase = "always";
      };
      merge = {
        ff = true;
      };
      pull = {
        rebase = true;
      };
      github = {
        user = "h-michael";
      };
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
      };
      "browse-remote \"github.com\"" = {
        top = "https://{host}/{path}";
        ref = "https://{host}/{path}/tree/{short_ref}";
        rev = "https://{host}/{path}/commit/{commit}";
      };
      gpg = {
        program = "gpg";
      };
      commit = {
        gpgsign = false;
      };
      http = {
        cookiefile = "~/.gitcookies";
      };
      init = {
        defaultBranch = "main";
      };
      # GitHub credential helper using gh CLI
      "credential \"https://github.com\"" = {
        helper = [
          ""
          "!gh auth git-credential"
        ];
      };
      "credential \"https://gist.github.com\"" = {
        helper = [
          ""
          "!gh auth git-credential"
        ];
      };
      # Aliases
      alias = {
        graph = "log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'";
        difff = "diff --word-diff";
      };
    };
  };

  # Delta (git diff pager) - now a separate program
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "side-by-side line-numbers decorations";
      whitespace-error-style = "22 reverse";
    };
  };

  xdg.configFile = {
    "git/ignore" = {
      source = ./files/ignore;
    };
  };
}
