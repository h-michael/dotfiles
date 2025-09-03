function fgc -d "git checkout selected branch"
  git branch | fzf --reverse | xargs git checkout
end