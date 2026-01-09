#!/usr/bin/env bash
# Close window with confirmation dialog

# Show confirmation dialog using rofi
choice=$(echo -e "Yes\nNo" | rofi -dmenu -p "Close this window?" -theme-str 'window {width: 300px;}')

if [ "$choice" = "Yes" ]; then
    hyprctl dispatch killactive
fi
