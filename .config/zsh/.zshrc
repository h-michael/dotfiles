#!/bin/zsh


#autoload -Uz compinit && compinit -u

# zmodload zsh/zprof && zprof

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# zinit ice wait atload"_zsh_autosuggest_start"
# zinit light zsh-users/zsh-autosuggestions

# zinit ice wait blockf atpull"zinit creinstall -q ."
# zinit light marlonrichert/zsh-autocomplete

# zinit light zsh-users/zsh-completions

# zinit ice wait atinit"zpcompinit; zpcdreplay"
# zinit light zdharma/fast-syntax-highlighting

# zinit wait lucid atload'_zsh_autosuggest_start' light-mode for \
zinit wait lucid light-mode for \
  zsh-users/zsh-autosuggestions \
  marlonrichert/zsh-autocomplete \
  zsh-users/zsh-completions \
  zdharma/fast-syntax-highlighting

# for config ($ZDOTDIR/*.zsh); do
#   source $config
# done

source $ZDOTDIR/setopt.zsh
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/keybinds.zsh
source $ZDOTDIR/alias.zsh
source $ZDOTDIR/fzf.zsh
source $ZDOTDIR/install_tools.zsh
source $ZDOTDIR/zstyle.zsh

if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)"

#if (which zprof > /dev/null 2>&1) ;then
#  zprof
#fi
