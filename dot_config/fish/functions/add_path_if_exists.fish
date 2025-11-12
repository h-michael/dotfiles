function add_path_if_exists -d "Add directory to PATH if it exists"
    for dir in $argv
        test -d $dir; and fish_add_path -m $dir
    end
end
