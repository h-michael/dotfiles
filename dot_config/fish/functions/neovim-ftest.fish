function neovim-ftest -d "Run Neovim functional tests for specific test file"
    set -l TEST_FILE $argv[1]
    set -l MIN_LOG_LEVEL 2
    set -l LOG_DIR $XDG_DATA_HOME/nvim/test/log
    set -l NVIM_LOG_FILE $XDG_DATA_HOME/nvim/test/.nvimlog
    set -l NVIM_TEST_TRACE_LEVEL 2
    # set -l BUSTED_ARGS '--coverage'
    # set -l USE_LUACOV 1
    make functionaltest \
        TEST_FILE=$TEST_FILE \
        BUSTED_PRG=(which -a busted) \
        MIN_LOG_LEVEL=2 \
        LOG_DIR=$XDG_DATA_HOME/nvim/test/log \
        NVIM_TEST_TRACE_LEVEL=2
    # BUSTED_ARGS='--coverage' \
    # USE_LUACOV=1 \
end
