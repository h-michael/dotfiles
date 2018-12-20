#!/bin/fish

rbenv update
nodenv update

if is_mac
  brew upgrade
  brew reinstall neovim
  brew reinstall tmux
  brew cleanup
  brew prune
end

rustup update
cargo install-update -a

if is_linux
  yay -Syu
end

fish -c fish_update_completions
