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
      "enpass" # password manager
      "alfred" # launcher
      "obsidian" # Knowledge base and note-taking

      # Development tools
      "bruno" # API client (Postman alternative, Git-friendly)
      "dbeaver-community" # Database management tool
      "wireshark-app" # Network protocol analyzer
    ];

    # CLI tools only available via Homebrew
    brews = [ ];
  };
}
