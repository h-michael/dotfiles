# Homebrew management via nix-darwin
{ ... }:

{
  # Add Homebrew to PATH
  environment.systemPath = [ "/opt/homebrew/bin" ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Remove unlisted packages
      upgrade = true;
    };

    # GUI applications (casks)
    casks = [
      "mqttx" # MQTT client GUI
      #"font-hack-nerd-font" # Nerd font
      "ghostty" # Terminal emulator
      "karabiner-elements" # Keyboard customization
    ];

    # CLI tools only available via Homebrew
    brews = [ ];
  };
}
