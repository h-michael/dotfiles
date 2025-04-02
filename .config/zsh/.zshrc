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

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

source $ZDOTDIR/setopt.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/keybinds.zsh
source $ZDOTDIR/alias.zsh
source $ZDOTDIR/fzf.zsh
source $ZDOTDIR/install_tools.zsh
source $ZDOTDIR/zstyle.zsh
source $ZDOTDIR/local/*.zsh

# https://github.com/zdharma-continuum/fast-syntax-highlighting#zinit
zinit wait'0' lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting

zinit wait'0' lucid light-mode for \
  zsh-users/zsh-autosuggestions \
  marlonrichert/zsh-autocomplete \
  zsh-users/zsh-completions

zinit wait'1' lucid light-mode for \
  zsh-users/zsh-history-substring-search

zinit wait'2' lucid light-mode for \
  jimhester/per-directory-history

if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)"
