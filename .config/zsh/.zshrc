#!/bin/zsh

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
#
zinit ice wait blockf atpull"zinit creinstall -q ."
zinit light zsh-users/zsh-completions
#
## zinit ice wait atinit"zpcompinit; zpcdreplay"
## zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions
# zinit light marlonrichert/zsh-autocomplete

if [ -z $TMUX ]; then
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
  fi

  # The next line enables shell command completion for gcloud.
  if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
  fi

  export INTERACTIVE_FILTER="fzf:peco:percol:gof:pick"
fi

for config ($ZDOTDIR/*.zsh); do
  source $config
done

if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)"
