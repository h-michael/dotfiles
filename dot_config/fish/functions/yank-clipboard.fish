function yank-clipboard -d "Copy stdin to tmux and system clipboard"
  set -l buf (cat)

  if set -q TMUX
    printf '%s' "$buf" | tmux load-buffer -
  end


  printf '%s' "$buf" | pbcopy
end