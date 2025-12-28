function clean-install-neovim -d "Clean build and install Neovim from source"
    cd (ghq root)/github.com/neovim/neovim
    rm -rf ./build
    make clean
    install-neovim $argv
end
