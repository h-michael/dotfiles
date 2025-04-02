# blank greeeting message
set fish_greeting

set -gx SHELL "$__fish_bin_dir"/fish

# load configuration files that are ignored by git
for conf in "$__fish_config_dir"/conf.local.d/*.fish
    source $conf
end

if is_mac
  /opt/homebrew/bin/brew shellenv | source
  fish_add_path $HOMEBREW_PREFIX/bin
  fish_add_path $HOMEBREW_PREFIX/sbin
  fish_add_path $HOMEBREW_PREFIX/libexec
  fish_add_path $HOMEBREW_PREFIX/opt/llvm/bin
end

# Haskell
fish_add_path $HOME/.cabal/bin

# Rust
fish_add_path $HOME/.cargo/bin

if [ -d "/usr/local/bin" ]
  set -gxp PATH /usr/local/bin
end

# Deno
if [ -d "$HOME/.deno/bin" ]
  fish_add_path $HOME/.deno/bin
end

# Lua
if [ -d "$HOME/.luarocks/bin" ]
  fish_add_path $HOME/.luarocks/bin
end

# Python
if [ -d "$HOME/.poetry/bin" ]
  fish_add_path $HOME/.poetry/bin
end

# Kubernetes
if [ -d "$HOME/.krew/bin" ]
  fish_add_path $HOME/.krew/bin
end

if [ -d "/usr/local/opt/gettext/bin" ]
  fish_add_path /usr/local/opt/gettext/bin
end

fish_add_path $HOME/.local/bin

direnv hook fish | source
# https://mise.jdx.dev/dev-tools/shims.html#shims-vs-path
#$HOME/.local/bin/mise activate fish | source
eval ($HOME/.local/bin/mise activate fish --shims)

# should execute the end of the config.fish
if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh
end

starship init fish | source
