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
    # programs.zsh would source hm-session-vars.sh for us; without it,
    # home.sessionVariables never reach zsh unless loaded here. The
    # profile directory differs between standalone HM and the NixOS module.
    ".zshenv".text = ''
      source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"

      ${builtins.readFile "${zshFilesPath}/zshenv"}
    '';
    ".zshrc".source = "${zshFilesPath}/zshrc";
  };
}
