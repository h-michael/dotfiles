zstyle ':completion:*' use-cache true
zstyle ':completion:*' verbose yes
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors "${LS_COLORS}"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:messages' format '%F{yellow}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{red}No matches for:''%F{yellow} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT

#zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
#
#zstyle ':completion:*' group-name ''
#
#zstyle ':completion:*' list-separator '--'
#zstyle ':completion:*:manuals' separate-sections true
