function chezmoi-diff -d "Show diff for both public and private chezmoi configurations"
    chezmoi diff $argv --config ~/.config/chezmoi/chezmoi.toml --source ~/.local/share/dotfiles/chezmoi &&
        chezmoi diff $argv --config ~/.config/chezmoi-private/chezmoi.toml --source ~/.local/share/dotfiles/chezmoi-private
end
