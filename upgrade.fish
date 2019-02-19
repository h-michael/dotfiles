#!/usr/local/bin/fish

read -s password

if is_mac
  rbenv update
  nodenv update

  brew upgrade
  brew reinstall neovim
  brew reinstall tmux
  brew cleanup
  brew prune
end

rustup update
rustup-toolchain-install-master -n master --force
cargo install-update -a

if is_linux
  echo $password | sudo -S yay -Syu  --noconfirm
  cd ~/ghq/github.com/h-michael/neovim
  git checkout master
  hub sync
  rm -rf build
  make clean
  make CMAKE_BUILD_TYPE=Release
  echo $password | sudo -S make install

  cd ~/ghq/github.com/h-michael/tmux
  git checkout master
  hub sync
  sh autogen.sh
  ./configure
  make
  echo $password | sudo -S make install

  cd ~/ghq/github.com/h-michael/alacritty
  git checkout master
  hub sync
  cargo build --release
  echo $password | sudo -S rm /usr/local/bin/alacritty
  echo $password | sudo -S cp target/release/alacritty /usr/local/bin/
  echo $password | sudo -S mkdir -p /usr/local/share/man/man1
  gzip -c alacritty.man | sudo -S tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null

  cd ~/ghq/github.com/fish-shell/fish-shell
  git checkout master
  hub sync
  rm -rf build
  mkdir build;
  cd build
  cmake ..
  make CMAKE_BUILD_TYPE=Release
  echo $password | sudo -S make install

  cd $HoME
end

fish -c fish_update_completions
