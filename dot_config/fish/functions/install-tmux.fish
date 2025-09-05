function install-tmux -d "Install tmux from source if updates are available"
    cd (ghq root)/github.com/tmux/tmux
    if check-outdate
        hub sync
        sh autogen.sh
        ./configure --prefix=$HOME/.local --enable-utf8proc --enable-sixel
        make -j 4
        make install
    end
end
