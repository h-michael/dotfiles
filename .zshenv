#!/bin/zsh

if [[ ! -f $HOME/.asdf/asdf.sh ]]; then
  git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
  cd $HOME/.asdf
  git checkout "$(git describe --abbrev=0 --tags)"
fi

# set package version manager path
. $HOME/.asdf/asdf.sh


# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_DATA_DIRS=/usr/local/share:/usr/share

ZDOTDIR=$XDG_CONFIG_HOME/zsh
source $ZDOTDIR/util.zsh

if [ -z $TMUX ]; then
  typeset -U path PATH
  if is_linux; then
    path=(
      $HOME/.local/bin(N-/)
      $HOME/.cabal/bin(N-/)
      $HOME/.cargo/bin(N-/)
      $HOME/go/bin(N-/)
      $path
    )
  fi
  if is_mac; then
    path=(
      $HOME/.local/bin(N-/)
      $HOME/.cabal/bin(N-/)
      $HOME/.cargo/bin(N-/)
      $HOME/go/bin(N-/)
      /opt/homebrew/bin(N-/)
      /opt/homebrew/sbin(N-/)
      /usr/local/bin(N-/)
      /usr/local/sbin(N-/)
      $path
    )
  fi

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/path.zsh.inc"
  fi

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

  export GTAGSCONF="$HOME/.globalrc"
  export GTAGSLIBPATH='/usr/lib/gtags'
  export GTAGSLABEL=pygments

  # For Enpass
  export QT_AUTO_SCREEN_SCALE_FACTOR=0

  export SSH_KEY_PATH=$HOME/.ssh/id_rsa
  if [ -n $SSH_CONNECTION ]; then
    export EDITOR=nvim
  fi

  if is_linux; then
    export BROWSER=google-chrome-stable
  fi
  if is_mac; then
    export BROWSER=open
    export LDFLAGS="-L$(brew --prefix)/lib "$LDFLAGS
    export CPPFLAGS="-I$(brew --prefix)/include "$CPPFLAGS
  fi

  export NVIM_SHARED_PATH=$HOME/.local/share/nvim
  export LSP_LOG_PATH=$NVIM_SHARED_PATH/vim-lsp.log

  # for Rust
  if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
  if command -v rustc &> /dev/null; then
    export RUST_SRC_PATH="$(rustc --print sysroot)"/lib/rustlib/src/rust/src
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(rustc --print sysroot)"/lib
  fi

  # Golang
  export GOPATH=$HOME/go

  eval "$(direnv hook zsh)"

  [ -f $ZDOTDIR/local/zsh.zsh ] && . $ZDOTDIR/local/zsh.zsh
fi
