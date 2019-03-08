#!/bin/sh

linux_link () {
  _common_link

  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/alacritty ~/.config/alacritty
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/fontconfig ~/.config/fontconfig
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/gtk-2.0 ~/.config/gtk-2.0
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/gtk-3.0/ ~/.config/gtk-3.0
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/powerline ~/.config/powerline
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/taffybar ~/.config/taffybar
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/conky ~/.config/conky
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/yay ~/.config/yay

  ln -sf ~/ghq/github.com/h-michael/dotfiles/.xmonad ~/.xmonad
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.xinitrc ~/.xinitrc
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.Xmodmap ~/.Xmodmap
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.xprofile ~/.xprofile
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.xsession ~/.xsession
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.Xresources ~/.Xresources
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.stalonetrayrc ~/.stalonetrayrc
}

mac_link () {
  _common_link

  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/alacritty_mac ~/.config/alacritty
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/karabiner ~/.config/karabiner
}

_common_link () {
  ln -sf ~/ghq/github.com/h-michael/dotfiles/upgrade.fish ~/upgrade.fish
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.vim ~/.vim
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.tmux.conf ~/.tmux.conf
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.tmux.conf.local ~/.tmux.conf.local
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.gitconfig ~/.gitconfig
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.gitignore_global ~/.gitignore_global
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.globalrc ~/.globalrc
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.pryrc ~/.pryrc

  if [ ! -d ~/.config ]; then
    mkdir ~/.config
  fi

  ln -sf ~/.vim ~/.config/nvim
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/fish ~/.config/fish
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/translate-shell/ ~/.config/translate-shell
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.config/pip ~/.config/pip

  if [ ! -d ~/.local/bin ]; then
    mkdir -p ~/.local/bin
  fi

  ln -sf ~/ghq/github.com/h-michael/dotfiles/.local/bin/yank ~/.local/bin/yank
  ln -sf ~/ghq/github.com/h-michael/dotfiles/.local/bin/check_distribution.sh ~/.local/bin
}

if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  mac_link
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  linux_link
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
