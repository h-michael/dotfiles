function reposize
  set dirs (ghq list -p)
  for dir in $dirs
    set dir_size (du -sm $dir)
    echo "$dir: $dir_size"
  end
end