function cdroot -d "Move to git repository root"
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -eq 0
        cd $git_root
    else
        echo "Error: Not inside a git repository"
        return 1
    end
end
