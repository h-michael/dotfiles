# Homebrew management via nix-darwin
{ ... }:

{
  # Add Homebrew to PATH
  environment.systemPath = [ "/opt/homebrew/bin" ];

  homebrew = {
    enable = true;

    onActivation = {
      # Run tap metadata refresh and cask upgrades manually so freshly
      # published versions aren't pulled in immediately by darwin-rebuild
      # switch. See `make brew-check` for the audited upgrade workflow.
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap"; # Remove unlisted packages
    };

    # GUI applications (casks)
    casks = [
      "mqttx" # MQTT client GUI
      "ghostty" # Terminal emulator
      "karabiner-elements" # Keyboard customization
      "enpass" # password manager
      "alfred" # launcher
      "obsidian" # Knowledge base and note-taking
      "cmux" # tmux session manager
      "cursor" # AI-powered code editor
      "visual-studio-code"

      # Development tools
      "bruno" # API client (Postman alternative, Git-friendly)
      "dbeaver-community" # Database management tool
      "wireshark-app" # Network protocol analyzer
    ];

    # CLI tools only available via Homebrew
    brews = [ ];
  };
}
