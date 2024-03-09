zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
# zstyle ':completion:*' verbose yes
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors "${LS_COLORS}"

zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:messages' format '%F{yellow}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{red}No matches for:''%F{yellow} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
