{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."lefthook/branch-protection.yml".source = ./files/branch-protection.yml;

  home.packages = [
    pkgs.lefthook
  ];
}
