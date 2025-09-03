function fgss -d "git stash show selected stash"
  git stash list | fzf --reverse --preview "echo {} | awk -F ':' '{print \$1}' | xargs git stash show -p | bat --color=always --style=numbers" | awk -F ':' '{print $1}'
end