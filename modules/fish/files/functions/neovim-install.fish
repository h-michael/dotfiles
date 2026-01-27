function neovim-install -d "Install Neovim from source with optional debug mode"
    cd (ghq root)/github.com/neovim/neovim

    set CMAKE_FLAGS ""
    set CMAKE_BUILD_TYPE RelWithDebInfo
    set CMAKE_EXTRA_FLAGS "-DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=$HOME/.local"
    if command -sq cmake
        set CMAKE_BIN (command -s cmake)
    end
    set CMAKE_EXTRA_FLAGS "$CMAKE_EXTRA_FLAGS -DCMAKE_COMMAND=$CMAKE_BIN"

    if [ $argv ]
        if [ $argv[1] = d ]
            set LOG_DIR "$HOME/.local/share/nvim/logs"
            # set CMAKE_FLAGS "$CMAKE_FLAGS -DPREFER_LUA=ON"
            set CMAKE_BUILD_TYPE Debug
            set CMAKE_EXTRA_FLAGS "$CMAKE_EXTRA_FLAGS -DMIN_LOG_LEVEL=0"
            # set CMAKE_EXTRA_FLAGS "$CMAKE_EXTRA_FLAGS -DCLANG_ASAN_UBSAN=ON -DSANITIZE_RECOVER_ALL=1"
            set CMAKE_EXTRA_FLAGS "$CMAKE_EXTRA_FLAGS -DCLANG_MASAN=ON"
            set UBSAN_OPTIONS "print_stacktrace=1 log_path=$LOG_DIR/ubsan"
            set ASAN_OPTIONS "halt_on_error=0:detect_leaks=1:log_path=$HOME/logs/asan"
            set TSAN_OPTIONS "log_path=$LOG_DIR/tsan"
        end
    end

    set CMAKE_FLAGS "$CMAKE_FLAGS -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"

    echo "======================================================================"
    echo "CMAKE_FLAGS=\"$CMAKE_FLAGS\""
    echo "CMAKE_BUILD_TYPE=\"$CMAKE_BUILD_TYPE\""
    echo "CMAKE_EXTRA_FLAGS=\"$CMAKE_EXTRA_FLAGS\""
    echo "======================================================================"

    make install -j 4 \
        CMAKE_INSTALL_PREFIX=$HOME/.local \
        CMAKE_FLAGS="$CMAKE_FLAGS" \
        CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS"
    cp ./build/compile_commands.json .

    echo "======================================================================"
    echo "CMAKE_FLAGS=\"$CMAKE_FLAGS\""
    echo "CMAKE_BUILD_TYPE=\"$CMAKE_BUILD_TYPE\""
    echo "CMAKE_EXTRA_FLAGS=\"$CMAKE_EXTRA_FLAGS\""
    echo "======================================================================"
end
