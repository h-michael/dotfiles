# macOS system defaults
{ ... }:

{
  system.defaults = {
    # Dock settings
    # https://mynixos.com/nix-darwin/options/system.defaults.dock
    dock = {
      autohide = true;
      tilesize = 43;
      show-recents = false;
      mru-spaces = false;
      # Hot Corners (13 = Lock Screen)
      wvous-bl-corner = 13; # Bottom Left: Lock Screen
    };

    # Finder settings
    # https://mynixos.com/nix-darwin/options/system.defaults.finder
    finder = {
      FXPreferredViewStyle = "clmv"; # Column view
      ShowStatusBar = false;
      AppleShowAllExtensions = true; # Always show file extensions
      AppleShowAllFiles = true; # Show hidden files
      _FXShowPosixPathInTitle = true; # Show full path in title
      QuitMenuItem = true; # Allow quitting Finder with Cmd+Q
      ShowPathbar = true; # Show path bar at bottom
      _FXSortFoldersFirst = true; # Sort folders before files
      NewWindowTarget = "Home"; # New windows open home folder
    };

    # Global settings
    # https://mynixos.com/nix-darwin/options/system.defaults.NSGlobalDomain
    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleInterfaceStyle = "Dark";
      # Disable auto-corrections (for developers)
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      # Disable press-and-hold for special characters (better for Vim)
      ApplePressAndHoldEnabled = false;
      # Don't save new documents to iCloud by default
      NSDocumentSaveNewDocumentsToCloud = false;
      # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    # Trackpad settings
    # https://mynixos.com/nix-darwin/options/system.defaults.trackpad
    trackpad = {
      Clicking = false;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };

    # Screenshot settings
    # https://mynixos.com/nix-darwin/options/system.defaults.screencapture
    screencapture = {
      location = "~/Documents/screenshot";
    };

    # Custom preferences for settings not directly exposed
    # https://mynixos.com/nix-darwin/options/system.defaults.CustomUserPreferences
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        # Don't create .DS_Store files on network drives
        DSDontWriteNetworkStores = true;
        # Don't create .DS_Store files on USB drives
        DSDontWriteUSBStores = true;
      };
    };
  };

  # Touch ID for sudo
  # https://mynixos.com/nix-darwin/options/security.pam
  security.pam.services.sudo_local.touchIdAuth = true;
}
