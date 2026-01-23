{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Primary user for user-specific settings (required for nix-darwin 25.11+)
  system.primaryUser = username;

  # Disable nix-darwin's Nix management (using Determinate Systems Installer)
  nix.enable = false;

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # AeroSpace tiling window manager
  services.aerospace = {
    enable = false;
    settings = {
      # Hyprland-inspired gaps (gaps_in=5, gaps_out=5)
      gaps = {
        inner.horizontal = 5;
        inner.vertical = 5;
        outer.left = 5;
        outer.right = 5;
        outer.top = 5;
        outer.bottom = 5;
      };

      # Default layout
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Key bindings (Hyprland-style with alt)
      mode.main.binding = {
        # Workspace switching (alt+1-0)
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        # Previous/next workspace (alt+h/l like Hyprland)
        alt-h = "workspace prev";
        alt-l = "workspace next";

        # Focus movement (arrow keys)
        alt-left = "focus left";
        alt-right = "focus right";
        alt-up = "focus up";
        alt-down = "focus down";

        # Move window to workspace (alt+shift+1-0)
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";

        # Move window directionally (alt+shift+arrow)
        alt-shift-left = "move left";
        alt-shift-right = "move right";
        alt-shift-up = "move up";
        alt-shift-down = "move down";

        # Fullscreen (alt+shift+enter)
        alt-shift-enter = "fullscreen";

        # Layout control
        alt-j = "layout tiles horizontal vertical";
        alt-comma = "layout tiles";
        alt-period = "layout accordion";

        # Application launcher (alt+p, like Hyprland)
        alt-p = "exec-and-forget open -a 'Alfred 5'";

        # Resize mode
        alt-r = "mode resize";

        # Close window (alt+shift+x, like Hyprland)
        alt-shift-x = "close";

        # Reload config
        alt-shift-c = "reload-config";
      };

      # Resize mode bindings
      mode.resize.binding = {
        left = "resize width -50";
        right = "resize width +50";
        up = "resize height -50";
        down = "resize height +50";
        enter = "mode main";
        esc = "mode main";
      };

      # Window rules (like Hyprland windowrule)
      on-window-detected = [
        # Float file managers
        {
          "if".app-id = "com.apple.finder";
          run = "layout floating";
        }
        # Float Discord/communication apps
        {
          "if".app-id = "com.hnc.Discord";
          run = "layout floating";
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "layout floating";
        }
      ];
    };
  };

  # Add fish to /etc/shells and set as default login shell
  environment.shells = [ pkgs.fish ];

  # All packages managed by home-manager (via useUserPackages = true)
  environment.systemPackages = [ ];

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  # Required for nix-darwin
  system.stateVersion = 6;
}
