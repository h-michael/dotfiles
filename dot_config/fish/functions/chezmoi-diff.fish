function chezmoi-diff
    chezmoi diff --config ~/.config/chezmoi/chezmoi.toml \
        --source ~/.local/share/dotfiles/chezmoi && chezmoi diff --config ~/.config/chezmoi-private/chezmoi.toml \
        --source ~/.local/share/dotfiles/chezmoi-private
end
