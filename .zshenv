#!/bin/zsh

source ~/.util.zsh

typeset -gx -U path
path=( \
    "$path[@]" \
    /usr/local/bin(N-/) \
    )
# NOTE: set fpath before compinit
typeset -gx -U fpath
fpath=( \
    ~/.zsh/(N-/) \
    /usr/share/zsh/site-functions(N-/) \
    /usr/local/share/zsh/site-functions(N-/) \
    $fpath \
    )

autoload -Uz is-at-least
autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz add-zsh-hook
autoload -Uz colors && colors
autoload -Uz compinit && compinit -u

# History
# History file
export HISTFILE=~/.zsh_history
# History size in memory
export HISTSIZE=10000
# The number of histsize
export SAVEHIST=1000000
# The size of asking history
export LISTMAX=50
# Do not add in root
if [[ $UID == 0 ]]; then
  unset HISTFILE
  export SAVEHIST=0
fi

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_DATA_DIRS=/usr/local/share:/usr/share

export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgreprc

# LANGUAGE must be set by en_US
export LANGUAGE=en_US.UTF-8
export LANG=$LANGUAGE
export LC_ALL=$LANGUAGE
export LC_CTYPE=$LANGUAGE

# for Alacritty
export COLORTERM='truecolor'

# Editor
export EDITOR=nvim
export CVSEDITOR=$EDITOR
export SVN_EDITOR=$EDITOR
export GIT_EDITOR=$EDITOR

# Pager
# export PAGER=page
export PAGER=less

export LESSCHARSET='utf-8'
export LESS='-R'
export LESSOPEN='|lessfilter=%s'

# LESS man page colors (makes Man pages more readable).
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;44;37m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# ls command colors
export CLICOLOR=true
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

export INTERACTIVE_FILTER="fzf:peco:percol:gof:pick"

export GTAGSCONF="$HOME/.globalrc"
export GTAGSLIBPATH='/usr/lib/gtags'
export GTAGSLABEL=pygments

[ -f ~/.secret.zsh ] && source ~/.secret.zsh

if is_linux; then
  export BROWSER=google-chrome-stable
fi

if is_mac; then
  export BROWSER=open
  export LDFLAGS "-L/usr/local/opt/gettext/lib"
  export CPPFLAGS "-I/usr/local/opt/gettext/include"
fi

# For Enpass
export QT_AUTO_SCREEN_SCALE_FACTOR=0

export SSH_KEY_PATH=$HOME/.ssh/id_rsa
if [ -n $SSH_CONNECTION ]; then
  export EDITOR=nvim
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

export DEIN_CACHE_PATH=$XDG_CACHE_HOME/dein-nvim/.cache
export NVIM_SHARED_PATH=$HOME/.local/share/nvim
export LSP_LOG_PATH=$NVIM_SHARED_PATH/vim-lsp.log

if [ -z $TMUX ]; then
  if is_mac; then
    export PATH="/usr/local/bin":$PATH
    export PATH="/usr/local/sbin":$PATH
    export PATH="/usr/local/opt/gettext/bin":$PATH
    export PATH=$HOME/google-cloud-sdk/bin:$PATH
  elif then;
    export PATH=$HOME/google-cloud-sdk/bin:$PATH
  fi

  export PATH=$PATH:/usr/local/bin
  export PATH=$HOME/.local/bin:$PATH

  # for Lua
  export LUA_LSP_DIR=$GOPATH/src/github.com/sumneko/lua-language-server
  export PATH=$HOME/.luarocks/bin:$PATH
  if is_linux; then
    export LUA_LSP_BIN=$LUA_LSP_DIR/bin/Linux/lua-language-server
  fi
  if is_mac; then
    export LUA_LSP_BIN=$LUA_LSP_DIR/bin/macOS/lua-language-server
  fi

  # for Haskell
  export PATH=$HOME/.cabal/bin:$PATH

  # for Rust
  export PATH=$HOME/.cargo/bin:$PATH
  export RUST_SRC_PATH="$(rustc --print sysroot)"/lib/rustlib/src/rust/src

  # for Rls
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(rustc --print sysroot)"/lib
  # export RUST_LOG "rls=debug"

  # Golang
  export GOENV_DISABLE_GOPATH=1
  export GO111MODULE=on
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$PATH

  if [[ ! -f $HOME/.asdf/asdf.sh ]]; then
    git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
    cd $HOME/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"
  fi

  # set package version manager path
  . $HOME/.asdf/asdf.sh
  . $HOME/.asdf/completions/asdf.bash

  # set langage version manager path
  # export PATH=$HOME/.anyenv/bin:$PATH
  # eval "$(anyenv init - --no-rehash)"

  export PATH=$PATH:$(yarn global bin)
  export PATH=$HOME/.local/bin:$PATH

  eval "$(direnv hook zsh)"
fi
