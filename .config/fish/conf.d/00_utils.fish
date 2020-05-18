function is_linux
  switch (uname)
    case Linux
      return 0
    case '*'
      return 1
  end
end

function is_mac
  switch (uname)
    case Darwin
      return 0
    case '*'
      return 1
  end
end

function pp_path
  echo $PATH | tr ' ' '\n'
end

function check_outdate
  git checkout master
  git fetch origin
  set UPSTREAM '@{u}'
  set LOCAL (git rev-parse @)
  set REMOTE (git rev-parse "$UPSTREAM")
  set BASE (git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]
    echo "Up-to-date"
    false
  else if [ $LOCAL = $BASE ]
    echo "Need to pull"
    true
  else if [ $REMOTE = $BASE ]
    echo "Need to push"
    false
  else
    echo "Diverged"
    false
  end
end

function install_neovim
  cd (ghq root)/github.com/h-michael/neovim

  set CMAKE_BUILD_TYPE "RelWithDebInfo"
  set CMAKE_EXTRA_FLAGS "-DCMAKE_EXPORT_COMPILE_COMMANDS=1"

  if [ $argv ]
    if [ $argv[1] = "d" ]
      set CMAKE_BUILD_TYPE "Debug"
      set CMAKE_EXTRA_FLAGS "$CMAKE_EXTRA_FLAGS -DMIN_LOG_LEVEL=0"
    end
  end

  echo $CMAKE_BUILD_TYPE
  echo $CMAKE_EXTRA_FLAGS

  make install -j 4\
    CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS" \
    CMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
    CMAKE_INSTALL_PREFIX=$HOME/.local
  cp ./build/compile_commands.json .
end

function clean_install_neovim
  cd (ghq root)/github.com/h-michael/neovim
  rm -rf ./build
  make clean
  install_neovim $argv
end

function neovim_ftest
  set -l TEST_FILE $argv[1]
  set -l MIN_LOG_LEVEL 2
  set -l LOG_DIR $HOME/.local/share/nvim/test/log
  set -l NVIM_LOG_FILE $HOME/.local/share/nvim/test/.nvimlog
  set -l NVIM_TEST_TRACE_LEVEL 2
  # set -l BUSTED_ARGS '--coverage'
  # set -l USE_LUACOV 1
  make functionaltest \
    TEST_FILE=$TEST_FILE \
    BUSTED_PRG=(which -a busted) \
    MIN_LOG_LEVEL=2 \
    LOG_DIR=$HOME/.local/share/nvim/test/log \
    NVIM_TEST_TRACE_LEVEL=2
    # BUSTED_ARGS='--coverage' \
    # USE_LUACOV=1 \
end

function install_tmux
  cd (ghq root)/github.com/tmux/tmux
  if check_outdate
    hub sync
    sh autogen.sh
    ./configure --prefix=$HOME/.local
    make
    make install
  end
end

function install_fish
  cd (ghq root)/github.com/fish-shell/fish-shell
  if check_outdate
    printf "input password"
    read -s password

    hub sync
    rm -rf build
    mkdir build
    cd build
    cmake ..
    make CMAKE_BUILD_TYPE=Release
    echo $password | sudo -S make install
  end
end

function install_alacritty
  cd (ghq root)/github.com/alacritty/alacritty
  if check_outdate
    printf "input password"
    read -s password

    hub sync
    cargo build --release
    echo $password | sudo -S rm /usr/local/bin/alacritty
    echo $password | sudo -S cp target/release/alacritty /usr/local/bin/
    echo $password | sudo -S mkdir -p /usr/local/share/man/man1
    echo $password | gzip -c extra/alacritty.man | sudo -S tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    mkdir -p $fish_complete_path[1]
    cp extra/completions/alacritty.fish $fish_complete_path[1]/alacritty.fish
  end
end

function install_lua_ls
  cd (ghq root)/github.com/sumneko/lua-language-server
  if check_outdate
    hub sync
    git submodule update --init --recursive
    cd 3rd/luamake

    if is_linux
      ninja -f ninja/linux.ninja
    elseif is_mac
      ninja -f ninja/macos.ninja
    end

    cd ../..
    ./3rd/luamake/luamake rebuild
  end
end

function upgrade_all_dev_tools
  printf "input password"
  read -s password

  if is_mac
    brew upgrade
    brew cleanup
    install_tmux
    install_alacritty
    cd $HOME
  end

  rustup update
  # rustup-toolchain-install-master -n master --force
  rustup default nightly
  cargo install-update -a
  rustup default stable
  anyenv update

  if is_linux
    set OS (check_distribution.sh)
    switch $OS
    case "Ubuntu"
      echo $password | sudo apt update
      echo $password | sudo apt upgrade
    case "Arch Linux"
      echo $password | sudo -S yay -Syu  --noconfirm --noanswerclean --noanswerdiff --noansweredit --noanswerupgrade
      install_alacritty
    case "*"
    end
    install_tmux
    install_fish
    cd $HOME
  end

  fish -c fish_update_completions
end
