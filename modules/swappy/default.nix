{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=%Y%m%d_%H%M%S.png
  '';
}
