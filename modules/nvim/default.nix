{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.neovim = {
    enable = true;

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
}
