{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.neovim = {
    enable = true;

    # Ruby/Python3 providers are disabled in lua/option.lua and unused by
    # any plugin here, so opt into the new (non-legacy) default.
    withRuby = false;
    withPython3 = false;

    # Add build tools for plugins that compile (treesitter, telescope-fzf-native)
    extraPackages = with pkgs; [
      gcc
      gnumake
      # For treesitter
      tree-sitter
      nodejs
      # For telescope
      ripgrep
      fd
    ];
  };

  xdg.configFile."nvim" = {
    source = ./files;
    recursive = true;
  };

  # lazy.nvim rewrites its lockfile on install/update, so link it to the
  # git checkout instead of the read-only store; updates then show up as
  # diffs to review and commit. Assumes the checkout lives at the ghq path.
  xdg.configFile."nvim/lazy-lock.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ghq/github.com/h-michael/dotfiles/modules/nvim/lazy-lock.json";
}
