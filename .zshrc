#!/bin/zsh

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

# for prompt
zinit snippet OMZ::lib/git.zsh
zinit snippet OMZ::plugins/vi-mode/vi-mode.plugin.zsh

# zinit ice wait blockf atpull"zinit creinstall -q ."
zinit light zsh-users/zsh-completions

# zinit ice wait atinit"zpcompinit; zpcdreplay"
zinit light zdharma/fast-syntax-highlighting
# zinit light zsh-users/zsh-syntax-highlighting

# zinit ice wait atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

for config (~/.zsh/*.zsh); do
  source $config
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
