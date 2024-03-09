#!/bin/zsh

if is_mac; then
  source $ZDOTDIR/env.zsh
fi

autoload -Uz is-at-least
autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz add-zsh-hook
autoload -Uz colors && colors
autoload -Uz compinit && compinit

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit wait lucid light-mode for \
  zsh-users/zsh-autosuggestions \
  marlonrichert/zsh-autocomplete \
  zsh-users/zsh-completions \
  zsh-users/zsh-history-substring-search \
  zdharma/fast-syntax-highlighting

source $ZDOTDIR/setopt.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/keybinds.zsh
source $ZDOTDIR/alias.zsh
source $ZDOTDIR/fzf.zsh
source $ZDOTDIR/install_tools.zsh
source $ZDOTDIR/zstyle.zsh
source $ZDOTDIR/local/*.zsh

if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)"
