function chezmoi-apply
    chezmoi apply --config ~/.config/chezmoi/chezmoi.toml \
        --source ~/.local/share/dotfiles/chezmoi && chezmoi apply --config ~/.config/chezmoi-private/chezmoi.toml \
        --source ~/.local/share/dotfiles/chezmoi-private
end
