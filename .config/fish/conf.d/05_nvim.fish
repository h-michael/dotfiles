function nvim_install
  cd $HOME/ghq/github.com/h-michael/neovim
  make install CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local
end

function nvim_ftest
  set TEST_FILE $argv[1]
  make functionaltest TEST_FILE=$TEST_FILE
end
