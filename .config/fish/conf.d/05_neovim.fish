function neovim_install
  cd $HOME/ghq/github.com/h-michael/neovim
  make install CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local
end

function neovim_clean_install
  cd $HOME/ghq/github.com/h-michael/neovim
  make clean
  make install CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local
end

function neovim_ftest
  set -l TEST_FILE $argv[1]
  set -l MIN_LOG_LEVEL 2
  set -l LOG_DIR $HOME/.local/share/nvim/test/log
  set -l NVIM_LOG_FILE $HOME/.local/share/nvim/test/.nvimlog
  set -l NVIM_TEST_TRACE_LEVEL 2
  env make functionaltest TEST_FILE=$TEST_FILE
end
