#!/bin/zsh

function check_outdate {
  git checkout master
  git fetch origin
  local UPSTREAM='@{u}'
  local LOCAL=$(git rev-parse @)
  local REMOTE=$(git rev-parse "$UPSTREAM")
  local BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
    false
  elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
    true
  elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
    false
  else
    echo "Diverged"
    false
  fi
}

function neovim_install {
  cd $(ghq root)/github.com/neovim/neovim
  make install CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local
}

function neovim_clean_install {
  cd $(ghq root)/github.com/neovim/neovim
  make clean
  make install CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local
}

function neovim_ftest {
  local TEST_FILE $argv[1]
  local MIN_LOG_LEVEL 2
  local LOG_DIR $HOME/.local/share/nvim/test/log
  local NVIM_LOG_FILE $HOME/.local/share/nvim/test/.nvimlog
  local NVIM_TEST_TRACE_LEVEL 2
  # local BUSTED_ARGS '--coverage'
  # local USE_LUACOV 1
  make functionaltest TEST_FILE=$TEST_FILE \
    BUSTED_PRG=$(which -a busted) \
    MIN_LOG_LEVEL=2 \
    LOG_DIR=$HOME/.local/share/nvim/test/log \
    NVIM_TEST_TRACE_LEVEL=2
    # BUSTED_ARGS='--coverage' \
    # USE_LUACOV=1 \
}

function install_tmux {
  cd $(ghq root)/github.com/tmux/tmux
  printf "input password\n"
  read -s password

  hub sync
  sh autogen.sh
  ./configure --enable-utf8proc --enable-sixel
  make
  echo $password | sudo -S make install
}

function install_latest_tmux {
  cd $(ghq root)/github.com/tmux/tmux
  if check_outdate; then
    printf "input password\n"
    read -s password

    hub sync
    sh autogen.sh
    ./configure --enable-utf8proc --enable-sixel
    make
    echo $password | sudo -S make install
  fi
}

function install_alacritty {
  cd $(ghq root)/github.com/alacritty/alacritty
  if check_outdate; then
    printf "input password\n"
    read -s password

    hub sync
    cargo build --release
    echo $password | sudo -S rm /usr/local/bin/alacritty
    echo $password | sudo -S cp target/release/alacritty /usr/local/bin/
    echo $password | sudo -S mkdir -p /usr/local/share/man/man1
    echo $password; gzip -c extra/alacritty.man | sudo -S tee /usr/local/share/man/man1/alacritty.1.gz 2> /dev/null
  fi
}
