function chezmoi-apply -d "Apply both public and private chezmoi configurations"
    chezmoi apply $argv --config ~/.config/chezmoi/chezmoi.toml --source ~/.local/share/dotfiles/chezmoi &&
        chezmoi apply $argv --config ~/.config/chezmoi-private/chezmoi.toml --source ~/.local/share/dotfiles/chezmoi-private
end
