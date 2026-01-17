{
  config,
  pkgs,
  lib,
  ...
}:

let
  qtctTokyonightPalette = ''
    [ColorScheme]
    active_colors=#ffc0caf5, #ff292e42, #ff3b4261, #ff3b4261, #ff16161e, #ff1f2335, #ffc0caf5, #ffffffff, #ffc0caf5, #ff1a1b26, #ff1f2335, #ff000000, #ff7aa2f7, #ff1a1b26, #ff7dcfff, #ff9d7cd8, #ff292e42, #ff000000, #ff292e42, #ffc0caf5, #80a9b1d6
    disabled_colors=#ff565f89, #ff292e42, #ff3b4261, #ff3b4261, #ff16161e, #ff1f2335, #ff565f89, #ff565f89, #ff565f89, #ff1a1b26, #ff1f2335, #ff000000, #ff3b4261, #ff565f89, #ff565f89, #ff565f89, #ff292e42, #ff000000, #ff292e42, #ff565f89, #80565f89
    inactive_colors=#ffa9b1d6, #ff292e42, #ff3b4261, #ff3b4261, #ff16161e, #ff1f2335, #ffa9b1d6, #ffffffff, #ffa9b1d6, #ff1a1b26, #ff1f2335, #ff000000, #ff7aa2f7, #ff1a1b26, #ff7dcfff, #ff9d7cd8, #ff292e42, #ff000000, #ff292e42, #ffa9b1d6, #80a9b1d6
  '';

  mkQtctConfig = dir: ''
    [Appearance]
    color_scheme_path=${config.xdg.configHome}/${dir}/colors/Tokyonight.conf
    custom_palette=true
    icon_theme=Breeze
    standard_dialogs=default
    style=Fusion
  '';
in
{
  # GTK Tokyonight theme
  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "Breeze";
      package = pkgs.kdePackages.breeze-icons;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-can-change-accels = 1;
      gtk-key-theme-name = "Emacs";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt dark theme (follows GTK)
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
  };

  xdg.configFile."qt5ct/qt5ct.conf".text = mkQtctConfig "qt5ct";
  xdg.configFile."qt5ct/colors/Tokyonight.conf".text = qtctTokyonightPalette;
  xdg.configFile."qt6ct/qt6ct.conf".text = mkQtctConfig "qt6ct";
  xdg.configFile."qt6ct/colors/Tokyonight.conf".text = qtctTokyonightPalette;

  # Set dark color scheme for portals/apps that support it
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
