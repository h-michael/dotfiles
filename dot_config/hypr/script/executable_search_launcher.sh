#!/usr/bin/env bash

set -euo pipefail

target=$(printf '%s\n' \
  "ArchWiki JP" \
  "ArchWiki EN" \
  "AUR" \
  "Arch Packages" \
  "Google" | \
  rofi -dmenu -i -p "Select Search Target" -no-custom)

# trap if rofi is closed
[[ -z ${target:-} ]] && exit 0

query=$(printf '' | rofi -dmenu -i -p "Search Word" \
                          -lines 0 -no-fixed-num-lines)

# trap if rofi is closed
[[ -z ${query:-} ]] && exit 0

encoded_query=$(printf '%s' "$query" | jq -sRr @uri)

case "$target" in
  "ArchWiki JP")
    url="https://wiki.archlinux.jp/index.php?search=${encoded_query}" ;;
  "ArchWiki EN")
    url="https://wiki.archlinux.org/index.php?search=${encoded_query}" ;;
  "AUR")
    url="https://aur.archlinux.org/packages?O=0&K=${encoded_query}" ;;
  "Arch Packages")
    url="https://archlinux.org/packages/?q=${encoded_query}" ;;
  "Google")
    url="https://www.google.com/search?q=${encoded_query}" ;;
  *)
    notify-send "Unknown target: $target"; exit 1 ;;
esac

xdg-open "$url" &

# wait until the browser is ready
sleep 0.5

desktop=$(xdg-settings get default-web-browser 2>/dev/null || echo firefox.desktop)
case "$desktop" in
  firefox-developer-edition.desktop)  target_browser=firefox                ;;
  firefox.desktop)                    target_browser=firefox                ;;
  *chrome*.desktop)                   target_browser=chrome                 ;;
  chromium*.desktop)                  target_browser=chromium               ;;
  brave-browser*.desktop)             target_browser=brave                  ;;
  *)                                  target_browser="${desktop%%.desktop}" ;;
esac

target_class=$(hyprctl clients | grep -iE "^\s*class: .*${target_browser}.*" | sed -E "s/.*class: (.*${target_browser}.*)/\1/gi" | head -n 1)

hyprctl dispatch focuswindow "class:^(?i)${target_class}$"

