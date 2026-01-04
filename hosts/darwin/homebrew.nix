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
      "ghostty" # Terminal emulator
      "karabiner-elements" # Keyboard customization

      # Nerd Fonts
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-fira-code-nerd-font"
    ];

    # CLI tools only available via Homebrew
    brews = [ ];
  };
}
