{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."satty/config.toml".text = ''
    [general]
    fullscreen = false
    default-hide-toolbars = true
    output-filename = "~/Pictures/Screenshots/%Y%m%d_%H%M%S.png"
    copy-command = "wl-copy"
  '';
}
