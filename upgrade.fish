#!/usr/local/bin/fish

read -s password

function check_outdate
  set UPSTREAM '@{u}'
  set LOCAL (git rev-parse @)
  set REMOTE (git rev-parse "$UPSTREAM")
  set BASE (git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]
    # echo "Up-to-date"
    false
  else if [ $LOCAL = $BASE ]
    #echo "Need to pull"
    true
  else if [ $REMOTE = $BASE ]
    # echo "Need to push"
    false
  else
    # echo "Diverged"
    false
  end
end

function upgrade_nvim
  cd ~/ghq/github.com/neovim/neovim
  git checkout master
  git fetch origin
  if check_outdate
    git pull
    rm -rf build
    make clean
    make CMAKE_BUILD_TYPE=Release
    echo $password | sudo -S make install
  end
end

function upgrade_tmux
  cd ~/ghq/github.com/tmux/tmux
  git checkout master
  git fetch origin
  if check_outdate
    hub sync
    sh autogen.sh
    ./configure
    make
    echo $password | sudo -S make install
  end
end

function upgrade_fish
  cd ~/ghq/github.com/fish-shell/fish-shell
  git checkout master
  git fetch origin
  if check_outdate
    hub sync
    rm -rf build
    mkdir build
    cd build
    cmake ..
    make CMAKE_BUILD_TYPE=Release
    echo $password | sudo -S make install
  end
end

function upgrade_alacritty
  cd ~/ghq/github.com/h-michael/alacritty

  git checkout master
  git fetch origin
  if check_outdate
    cargo build --release
    echo $password | sudo -S rm /usr/local/bin/alacritty
    echo $password | sudo -S cp target/release/alacritty /usr/local/bin/
    echo $password | sudo -S mkdir -p /usr/local/share/man/man1
    gzip -c alacritty.man | sudo -S tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
  end
end

if is_mac
  rbenv update
  nodenv update

  brew upgrade
  brew reinstall neovim
  brew reinstall tmux
  brew cleanup
  brew prune
  upgrade_alacritty
  cd $HOME
end

rustup update
# rustup-toolchain-install-master -n master --force
rustup default nightly
cargo install-update -a
rustup default stable

if is_linux
  set OS (check_distribution.sh)
  switch $OS
  case "Ubuntu"
    echo $password | sudo apt update
    echo $password | sudo apt upgrade
  case "Arch Linux"
    echo $password | sudo -S yay -Syu  --noconfirm --noanswerclean --noanswerdiff --noansweredit --noanswerupgrade
    upgrade_alacritty
  case "*"
  end
  upgrade_nvim
  upgrade_tmux
  upgrade_fish
  cd $HOME
end

fish -c fish_update_completions
