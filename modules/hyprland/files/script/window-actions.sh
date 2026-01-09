#!/usr/bin/env bash
# Window actions menu for Hyprland

# Define window actions
actions=(
    "Center window"
    "Pin window (all workspaces)"
    "Toggle floating"
    "Toggle fullscreen"
    "Close window"
)

# Show rofi menu
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "Window Actions" -theme-str 'window {width: 400px;}')

# Execute selected action
case "$selected" in
    "Center window")
        hyprctl dispatch centerwindow
        ;;
    "Pin window (all workspaces)")
        hyprctl dispatch pin
        ;;
    "Toggle floating")
        hyprctl dispatch togglefloating
        ;;
    "Toggle fullscreen")
        hyprctl dispatch fullscreen
        ;;
    "Close window")
        # Show confirmation dialog
        choice=$(echo -e "Yes\nNo" | rofi -dmenu -p "Close this window?" -theme-str 'window {width: 300px;}')
        if [ "$choice" = "Yes" ]; then
            hyprctl dispatch killactive
        fi
        ;;
esac
