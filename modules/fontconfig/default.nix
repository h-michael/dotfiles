{
  config,
  pkgs,
  lib,
  ...
}:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "Cica"
        "Noto Sans Mono CJK JP"
      ];
      sansSerif = [ "Noto Sans CJK JP" ];
      serif = [ "Noto Serif CJK JP" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
