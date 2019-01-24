#!/bin/sh

linux_link () {
  _common_link

  ln -sf ~/Dropbox/dotfiles/.config/alacritty ~/.config/alacritty
  ln -sf ~/Dropbox/dotfiles/.config/fontconfig ~/.config/fontconfig
  ln -sf ~/Dropbox/dotfiles/.config/gtk-2.0 ~/.config/gtk-2.0
  ln -sf ~/Dropbox/dotfiles/.config/gtk-3.0/ ~/.config/gtk-3.0
  ln -sf ~/Dropbox/dotfiles/.config/powerline ~/.config/powerline
  ln -sf ~/Dropbox/dotfiles/.config/taffybar ~/.config/taffybar
  ln -sf ~/Dropbox/dotfiles/.config/conky ~/.config/conky

  ln -sf ~/Dropbox/dotfiles/.xmonad ~/.xmonad
  ln -sf ~/Dropbox/dotfiles/.xinitrc ~/.xinitrc
  ln -sf ~/Dropbox/dotfiles/.Xmodmap ~/.Xmodmap
  ln -sf ~/Dropbox/dotfiles/.xprofile ~/.xprofile
  ln -sf ~/Dropbox/dotfiles/.xsession ~/.xsession
  ln -sf ~/Dropbox/dotfiles/.Xresources ~/.Xresources
  ln -sf ~/Dropbox/dotfiles/.stalonetrayrc ~/.stalonetrayrc
}

mac_link () {
  _common_link

  ln -sf ~/Dropbox/dotfiles/.config/alacritty_mac ~/.config/alacritty
  ln -sf ~/Dropbox/dotfiles/.config/karabiner ~/.config/karabiner
}

_common_link () {
  ln -sf ~/Dropbox/dotfiles/upgrade.fish ~/upgrade.fish
  ln -sf ~/Dropbox/dotfiles/.vim ~/.vim
  ln -sf ~/Dropbox/dotfiles/.tmux.conf ~/.tmux.conf
  ln -sf ~/Dropbox/dotfiles/.tmux.conf.local ~/.tmux.conf.local
  ln -sf ~/Dropbox/dotfiles/.gitconfig ~/.gitconfig
  ln -sf ~/Dropbox/dotfiles/.gitignore_global ~/.gitignore_global
  ln -sf ~/Dropbox/dotfiles/.globalrc ~/.globalrc
  ln -sf ~/Dropbox/dotfiles/.pryrc ~/.pryrc

  if [ ! -d ~/.config ]; then
    mkdir ~/.config
  fi

  ln -sf ~/.vim ~/.config/nvim
  ln -sf ~/Dropbox/dotfiles/.config/fish ~/.config/fish
  ln -sf ~/Dropbox/dotfiles/.config/translate-shell/ ~/.config/translate-shell
  ln -sf ~/Dropbox/dotfiles/.config/pip ~/.config/pip

  if [ ! -d ~/.local/bin ]; then
    mkdir -p ~/.local/bin
  fi

  ln -sf ~/Dropbox/dotfiles/.local/bin/yank ~/.local/bin/yank
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

#ln -sf ~/Dropbox/dotfiles/. ~/.
#ln -sf ~/Dropbox/dotfiles/.config/ ~/.config/
