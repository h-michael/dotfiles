{ pkgs, ... }:

let
  herdrSwitch = pkgs.writeShellApplication {
    name = "herdr-switch";
    runtimeInputs = [
      pkgs.fzf
      pkgs.jq
    ];
    text = builtins.readFile ./files/herdr-switch.sh;
  };
in
{
  home.packages = [ herdrSwitch ];

  xdg.configFile."herdr/config.toml".source = ./files/config.toml;
}
