{
  config,
  pkgs,
  lib,
  ...
}:

let
  zshFilesPath = ./files;
in
{
  home.packages = [ pkgs.zsh ];

  # Manage raw zsh dotfiles directly (mirrors the file-based fish module)
  # instead of programs.zsh, which injects its own boilerplate into the
  # generated .zshrc/.zshenv.
  home.file = {
    ".zshenv".source = "${zshFilesPath}/zshenv";
    ".zshrc".source = "${zshFilesPath}/zshrc";
  };
}
