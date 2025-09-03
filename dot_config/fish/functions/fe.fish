# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fe
  set file (fzf --query="$1" --select-1 --exit-0)
  [ -n $file ]; and nvim $file
end