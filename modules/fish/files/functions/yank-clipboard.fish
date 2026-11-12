function yank-clipboard -d "Copy stdin to tmux and system clipboard"
    # yank (modules/scripts) copies via OSC 52 and tmux on every platform
    yank
end
