function cargo-check-nowarn -d "Run cargo check with warnings suppressed via RUSTFLAGS"
    set -l dir ''
    set -l args

    if count $argv >0
        # If the first argument is a directory, treat it as the working directory
        if test -d $argv[1]
            set dir $argv[1]
            set args $argv[2..-1]
        else
            set args $argv
        end
    end

    if test -n "$dir"
        pushd $dir >/dev/null
    end

    env RUSTFLAGS='-Awarnings' cargo check $args

    if test -n "$dir"
        popd >/dev/null
    end
end
