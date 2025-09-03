function fgadd -d "git add selected files"
  git status -s | grep -e '^ M ' | sed -e 's/^ M //' | fzf --multi | xargs git add; and git status -s
end