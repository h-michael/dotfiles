function lsize -d "Show size of directories in current directory"
    set dirs (ls -a)
    for dir in $dirs
        set dir_size (du -sm $dir)
        echo "$dir: $dir_size"
    end
end
