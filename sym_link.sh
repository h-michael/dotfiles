#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

linux_link () {
  _common_link

  ln -sf $DIR/.config/ghostty/config_linux ~/.config/ghostty/config_linux
  ln -sf $DIR/.config/arch/alacritty ~/.config/alacritty
  ln -sf $DIR/.config/arch/fontconfig ~/.config/fontconfig
  ln -sf $DIR/.config/arch/i3 ~/.config/i3
  ln -sf $DIR/.config/arch/polybar ~/.config/polybar
  ln -sf $DIR/.config/arch/rofi ~/.config/rofi
  ln -sf $DIR/.config/arch/sway ~/.config/sway
  ln -sf $DIR/.config/arch/gtk-2.0 ~/.config/gtk-2.0
  ln -sf $DIR/.config/arch/gtk-3.0 ~/.config/gtk-3.0
  ln -sf $DIR/.config/arch/conky ~/.config/conky

  ln -sf $DIR/.config/arch/xmonad ~/.xmonad
  ln -sf $DIR/.config/arch/xinitrc ~/.xinitrc
  ln -sf $DIR/.config/arch/Xmodmap ~/.Xmodmap
  ln -sf $DIR/.config/arch/Xmodmap_default ~/.Xmodmap_default
  ln -sf $DIR/.config/arch/xprofile ~/.xprofile
  ln -sf $DIR/.config/arch/xsession ~/.xsession
  ln -sf $DIR/.config/arch/Xresources ~/.Xresources
  ln -sf $DIR/.config/arch/stalonetrayrc ~/.stalonetrayrc
}

mac_link () {
  _common_link

  ln -sf $DIR/.config/ghostty/config_mac ~/.config/ghostty/config_mac
  ln -sf $DIR/.config/mac/alacritty ~/.config/alacritty
  ln -sf $DIR/.config/mac/karabiner ~/.config/karabiner
}

_common_link () {
  if [ ! -d ~/.config ]; then
    mkdir ~/.config
  fi

  ln -sf $DIR/.vim ~/.vim
  ln -sf ~/.vim ~/.config/nvim
  ln -sf $DIR/.tmux.conf ~/.tmux.conf
  ln -sf $DIR/.tmux.conf.local ~/.tmux.conf.local
  ln -sf $DIR/.globalrc ~/.globalrc
  ln -sf $DIR/.pryrc ~/.pryrc
  ln -sf $DIR/.util.zsh ~/.util.zsh
  ln -sf $DIR/.zshenv ~/.zshenv
  ln -sf $DIR/.zsh ~/.config/zsh
  if [ ! -d ~/.config/ghostty ]; then
    mkdir ~/.config/ghostty
    ln -sf $DIR/.config/ghostty/config ~/.config/ghostty/config
  fi
  ln -sf $DIR/.config/git ~/.config/git
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
