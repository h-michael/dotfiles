# Vim-like keybind as default
bindkey -v
# Vim-like escaping ^[ keybind
bindkey -M viins '^[' vi-cmd-mode

# Add emacs-like keybind to viins mode
bindkey -M viins '^L'  forward-char
bindkey -M viins '^H'  backward-char

autoload -Uz up-line-or-beginning-search
zle -N up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M viins '^P'  up-line-or-beginning-search
bindkey -M viins '^N'  down-line-or-beginning-search
#bindkey -M viins '^P'  up-line-or-history
#bindkey -M viins '^N'  down-line-or-history

bindkey -M viins '^A'  beginning-of-line
bindkey -M viins '^E'  end-of-line
bindkey -M viins '^K'  kill-line
#bindkey -M viins '^R'  history-incremental-pattern-search-backward
#bindkey -M viins '\er' history-incremental-pattern-search-forward
bindkey -M viins '^Y'  yank
bindkey -M viins '^W'  backward-kill-word
bindkey -M viins '^U'  backward-kill-line
bindkey -M viins '^B'  backward-delete-char
bindkey -M viins '^?'  backward-delete-char
bindkey -M viins '^G'  send-break
bindkey -M viins '^D'  delete-char-or-list

bindkey -M vicmd '^A'  beginning-of-line
bindkey -M vicmd '^E'  end-of-line
bindkey -M vicmd '^K'  kill-line
bindkey -M vicmd '^P'  up-line-or-beginning-search
bindkey -M vicmd '^N'  down-line-or-beginning-search
#bindkey -M vicmd '^P'  up-line-or-history
#bindkey -M vicmd '^N'  down-line-or-history
bindkey -M vicmd '^Y'  yank
bindkey -M vicmd '^W'  backward-kill-word
bindkey -M vicmd '^U'  backward-kill-line
bindkey -M vicmd '/'   vi-history-search-forward
bindkey -M vicmd '?'   vi-history-search-backward

bindkey -M vicmd 'gg' beginning-of-line
bindkey -M vicmd 'G'  end-of-line

if is-at-least 5.0.8; then
    autoload -Uz surround
    zle -N delete-surround surround
    zle -N change-surround surround
    zle -N add-surround surround
    bindkey -a cs change-surround
    bindkey -a ds delete-surround
    bindkey -a ys add-surround
    bindkey -a S add-surround
fi

bindkey -M viins '^Xq' quote-previous-word-in-double

bindkey -M viins "$terminfo[kcbt]" reverse-menu-complete

# https://github.com/zsh-users/zsh-autosuggestions#key-bindings
bindkey -M viins '^F' autosuggest-accept
