function chezmoi-cd -d "Move to chezmoi or chezmoi-private source directory"
    set -l choices chezmoi chezmoi-private
    set -l choice (printf "%s\n" $choices | fzf --prompt="Select chezmoi source: ")

    if test -n "$choice"
        switch $choice
            case chezmoi
                cd ~/.local/share/dotfiles/chezmoi
            case chezmoi-private
                cd ~/.local/share/dotfiles/chezmoi-private
        end
    end
end
