# blank greeeting message
set fish_greeting

# XDG Base Directory
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share

# LANGUAGE must be set by en_US

set -x LANGUAGE en_US.UTF-8
set -x LANG $LANGUAGE
set -x LC_ALL $LANGUAGE
set -x LC_CTYPE $LANGUAGE

# for Alacritty
set -x COLORTERM 'truecolor'

# Editor
set -x EDITOR nvim
set -x CVSEDITOR $EDITOR
set -x SVN_EDITOR $EDITOR
set -x GIT_EDITOR $EDITOR

# Pager
# set -x PAGER page
set -x PAGER less

set -x LESSCHARSET 'utf-8'
set -x LESS '-R'
set -x LESSOPEN '|lessfilter %s'

# LESS man page colors (makes Man pages more readable).
set -x LESS_TERMCAP_mb (printf "\033[01;31m")
set -x LESS_TERMCAP_md (printf "\033[01;31m")
set -x LESS_TERMCAP_me (printf "\033[0m")
set -x LESS_TERMCAP_se (printf "\033[0m")
set -x LESS_TERMCAP_so (printf "\033[01;44;33m")
set -x LESS_TERMCAP_ue (printf "\033[0m")
set -x LESS_TERMCAP_us (printf "\033[01;32m")

# ls command colors
set -x CLICOLOR true
set -x LSCOLORS exfxcxdxbxegedabagacad
set -x LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

set -x INTERACTIVE_FILTER "fzf:peco:percol:gof:pick"

set -x GTAGSCONF "$HOME/.globalrc"
set -x GTAGSLIBPATH '/usr/lib/gtags'
set -x GTAGSLABEL pygments

[ -f ~/.secret ]; and source ~/.secret

if is_linux
    set -x BROWSER google-chrome-stable
end

if is_mac
    set -x BROWSER open
end

# For Enpass
set -x QT_AUTO_SCREEN_SCALE_FACTOR 0

if [ -z $TMUX ]
  # set langage version manager path
  set -x PATH $HOME/.rbenv/bin $PATH
  set -x PATH $HOME/.nodenv/bin $PATH

  set -x PATH $PATH /usr/local/bin
  set -x PATH $HOME/.local/bin $PATH

  # for Haskell
  set -x PATH $HOME/.cabal/bin $PATH

  # for Rust
  set -x PATH $PATH $HOME/.cargo/bin

  set -x RUST_SRC_PATH (rustc --print sysroot)/lib/rustlib/src/rust/src
  # for Rls
  set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH (rustc --print sysroot)/lib

  # xenv
  set -x PATH $HOME/.rbenv/bin $PATH
  set -x PATH $HOME/.nodenv/bin $PATH
  set -x GOPATH $HOME/go
  set -x PATH $PATH $GOPATH/bin
  set -x GOENV_ROOT $HOME/.goenv
  set -x PATH $GOENV_ROOT/bin $PATH

  # Display
  set -g theme_color_scheme gruvbox
  set -g theme_display_docker_machine no
  set -g theme_display_virtualenv no
end

eval (direnv hook fish)

if status --is-interactive
  source (rbenv init -|psub)
  source (nodenv init -|psub)
  # set -x PATH $PATH (yarn global bin)
  source (goenv init -|psub)
end

set -x SSH_KEY_PATH $HOME/.ssh/id_rsa
if [ -n $SSH_CONNECTION ]
  set -x EDITOR nvim
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.fish.inc" ]
  source "$HOME/google-cloud-sdk/path.fish.inc"
end

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.fish.inc" ]
  source "$HOME/google-cloud-sdk/completion.fish.inc"
end

if [ -f "/usr/local/sbin" ]
  set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
end

function history-merge --on-event fish_preexec
  history --save
  history --merge
end
