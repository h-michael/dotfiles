function gitaddm -d "git add modified files"
    set -l root (git rev-parse --show-toplevel); or return
    # Paths from git diff are relative to the repository root
    set -l files (git -C $root diff --name-only --diff-filter=M)
    test -n "$files"; and git -C $root add -- $files
end
