function fdh -d "Delete selected command from history"
    history | fzf | read -l item; and history delete --prefix "$item"
end
