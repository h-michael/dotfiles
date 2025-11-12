function chezmoi-cd -d "Move to dotfile root or chezmoi or chezmoi-private source directory"
    set -l choices dotfile-root chezmoi chezmoi-private
    set -l choice (printf "%s\n" $choices | fzf --prompt="Select chezmoi source: ")

    if test -n "$choice"
        switch $choice
            case dotfile-root
                cd ~/.local/share/dotfiles
            case chezmoi
                cd ~/.local/share/dotfiles/chezmoi
            case chezmoi-private
                cd ~/.local/share/dotfiles/chezmoi-private
        end
    end
end
