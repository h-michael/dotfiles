function fgdb -d "git delete selected branch"
  git branch | fzf --multi | xargs git branch -D
end