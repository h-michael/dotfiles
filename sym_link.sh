#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

linux_link () {
  _common_link

  ln -sf $DIR/.config/alacritty ~/.config/alacritty
  ln -sf $DIR/.config/fontconfig ~/.config/fontconfig
  ln -sf $DIR/.config/i3 ~/.config/i3
  ln -sf $DIR/.config/polybar ~/.config/polybar
  ln -sf $DIR/.config/rofi ~/.config/rofi
  ln -sf $DIR/.config/sway ~/.config/sway
  ln -sf $DIR/.config/gtk-2.0 ~/.config/gtk-2.0
  ln -sf $DIR/.config/gtk-3.0 ~/.config/gtk-3.0
  ln -sf $DIR/.config/powerline ~/.config/powerline
  ln -sf $DIR/.config/taffybar ~/.config/taffybar
  ln -sf $DIR/.config/conky ~/.config/conky
  ln -sf $DIR/.config/yay ~/.config/yay

  ln -sf $DIR/.xmonad ~/.xmonad
  ln -sf $DIR/.xinitrc ~/.xinitrc
  ln -sf $DIR/.Xmodmap ~/.Xmodmap
  ln -sf $DIR/.Xmodmap_default ~/.Xmodmap_default
  ln -sf $DIR/.xprofile ~/.xprofile
  ln -sf $DIR/.xsession ~/.xsession
  ln -sf $DIR/.Xresources ~/.Xresources
  ln -sf $DIR/.stalonetrayrc ~/.stalonetrayrc
}

mac_link () {
  _common_link

  ln -sf $DIR/.config/alacritty_mac ~/.config/alacritty
  ln -sf $DIR/.config/karabiner ~/.config/karabiner
}

_common_link () {
  ln -sf $DIR/.vim ~/.vim
  ln -sf $DIR/.tmux.conf ~/.tmux.conf
  ln -sf $DIR/.tmux.conf.local ~/.tmux.conf.local
  ln -sf $DIR/.gitconfig ~/.gitconfig
  ln -sf $DIR/.gitignore_global ~/.gitignore_global
  ln -sf $DIR/.globalrc ~/.globalrc
  ln -sf $DIR/.pryrc ~/.pryrc

  if [ ! -d ~/.config ]; then
    mkdir ~/.config
  fi

  ln -sf ~/.vim ~/.config/nvim
  ln -sf $DIR/.config/fish ~/.config/fish
  ln -sf $DIR/.config/translate-shell/ ~/.config/translate-shell
  ln -sf $DIR/.config/pip ~/.config/pip
  ln -sf $DIR/.config/ripgreprc ~/.config/ripgreprc

  if [ ! -d ~/.local/bin ]; then
    mkdir -p ~/.local/bin
  fi

  ln -sf $DIR/.local/bin/yank ~/.local/bin/yank
  ln -sf $DIR/.local/bin/check_distribution.sh ~/.local/bin
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

cp $DIR/.minimal_nvimrc $HOME/
cp $DIR/.minimal_vimrc $HOME/
