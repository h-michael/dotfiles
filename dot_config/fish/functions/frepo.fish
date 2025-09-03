function frepo -d "cd to selected git repository"
  set dir (ghq list | fzf +m)
  cd (ghq root)/$dir
end