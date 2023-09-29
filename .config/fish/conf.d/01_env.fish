if [ -z $TMUX ]
  # blank greeeting message
  set fish_greeting

  eval (ssh-agent -c)
  if is_mac
      ssh-add --apple-use-keychain
  else
    ssh-add -K
  end

  # XDG Base Directory
  set -gx XDG_CONFIG_HOME $HOME/.config
  set -gx XDG_CACHE_HOME $HOME/.cache
  set -gx XDG_DATA_HOME $HOME/.local/share
  set -gx XDG_CONFIG_DIRS /etc/xdg
  set -gx XDG_DATA_DIRS /usr/local/share:/usr/share

  set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgreprc

  # LANGUAGE must be set by en_US
  set -gx LANGUAGE en_US.UTF-8
  set -gx LANG $LANGUAGE
  set -gx LC_ALL $LANGUAGE
  set -gx LC_CTYPE $LANGUAGE

  # for Alacritty
  set -gx COLORTERM 'truecolor'

  # Editor
  set -gx EDITOR nvim
  set -gx CVSEDITOR $EDITOR
  set -gx SVN_EDITOR $EDITOR
  set -gx GIT_EDITOR $EDITOR

  # Pager
  # set -x PAGER page
  set -gx PAGER less

  # Less
  set -gx LESSCHARSET 'utf-8'
  set -gx LESS '-R'
  set -gx LESSOPEN '|lessfilter %s'

  # LESS man page colors (makes Man pages more readable).
  set -gx LESS_TERMCAP_mb (printf "\033[01;31m")
  set -gx LESS_TERMCAP_md (printf "\033[01;31m")
  set -gx LESS_TERMCAP_me (printf "\033[0m")
  set -gx LESS_TERMCAP_se (printf "\033[0m")
  set -gx LESS_TERMCAP_so (printf "\033[01;44;33m")
  set -gx LESS_TERMCAP_ue (printf "\033[0m")
  set -gx LESS_TERMCAP_us (printf "\033[01;32m")

  # ls command colors
  set -gx CLICOLOR true
  set -gx LSCOLORS exfxcxdxbxegedabagacad
  set -gx LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

  set -gx INTERACTIVE_FILTER "fzf:peco:percol:gof:pick"

  # gtags
  set -gx GTAGSCONF "$HOME/.globalrc"
  set -gx GTAGSLIBPATH '/usr/lib/gtags'
  set -gx GTAGSLABEL pygments

  [ -f ~/.secret ]; and source ~/.secret

  if is_linux
    set -gx BROWSER google-chrome-stable
  else if is_mac
    set -gxp BROWSER open
    set -gxp PATH /opt/homebrew/bin
    set -gxp PATH "$(brew --prefix)/bin"
    set -gxp PATH "$(brew --prefix)/sbin"
    set -gxp PATH "$(brew --prefix)/libexec"
    set -gxp LDFLAGS "-L$(brew --prefix)/lib"
    set -gxp CPPFLAGS "-I$(brew --prefix)/include"
    set -gxp CPPFLAGS "-I$(brew --prefix)/include/boost"
  end

  # For Enpass
  set -gx QT_AUTO_SCREEN_SCALE_FACTOR 0

  set -gx SSH_KEY_PATH $HOME/.ssh/id_rsa
  if [ -n $SSH_CONNECTION ]
    set -x EDITOR nvim
  end

  #if [ -d "$HOME/google-cloud-sdk/bin" ]
  #  set -gx PATH "$HOME/google-cloud-sdk/bin" $PATH
  #end

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "$HOME/google-cloud-sdk/path.fish.inc" ]
    source "$HOME/google-cloud-sdk/path.fish.inc"
  end

  # The next line enables shell command completion for gcloud.
  if [ -f "$HOME/google-cloud-sdk/completion.fish.inc" ]
    source "$HOME/google-cloud-sdk/completion.fish.inc"
  end

  # Nvim
  set -gx DEIN_CACHE_PATH $XDG_CACHE_HOME/dein-nvim/.cache
  set -gx NVIM_SHARED_PATH $HOME/.local/share/nvim
  set -gx LSP_LOG_PATH $NVIM_SHARED_PATH/lsp.log

  if [ -d "/usr/local/bin" ]
    set -gxp PATH /usr/local/bin
  end

  source ~/.asdf/asdf.fish

  # for Haskell
  set -gxp PATH $HOME/.cabal/bin

  # for Rust
  set -gxp PATH $HOME/.cargo/bin
  set -gx RUST_SRC_PATH (rustc --print sysroot)/lib/rustlib/src/rust/src

  # for Rls
  set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH (rustc --print sysroot)/lib
  # set -x RUST_LOG "rls=debug"

  # for Golang
  if is_mac
    set -gx GOROOT /opt/homebrew/opt/go/libexec/
  end

  # Lua
  if [ -d "$HOME/.luarocks/bin" ]
    set -gxp PATH $HOME/.luarocks/bin
  end
  set -gx LUA_LSP_DIR $GOPATH/src/github.com/sumneko/lua-language-server
  set -gx LUA_LSP_BIN $LUA_LSP_DIR/bin/lua-language-server

  # Python
  if [ -d "$HOME/.poetry/bin" ]
    set -gxp PATH $HOME/.poetry/bin
  end

  # Kubernetes
  if [ -d "$HOME/.krew/bin" ]
    set -gxp PATH $HOME/.krew/bin
  end

  # Display
  set -g theme_color_scheme gruvbox
  set -g theme_display_docker_machine no
  set -g theme_display_virtualenv no

  # set -gx PATH /usr/local/opt/gettext/bin $PATH

  set -gx DENO_INSTALL $HOME/.deno
  set -gxp PATH $DENO_INSTALL/bin

  set -gxp PATH $HOME/.local/bin
end

direnv hook fish | source
