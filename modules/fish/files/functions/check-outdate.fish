function check-outdate -d "Check if current git branch needs update from remote"
    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    if test -z "$default_branch"
        echo "Error: Could not determine the default branch." >&2
        return 1
    end

    git checkout $default_branch
    git fetch origin
    set UPSTREAM '@{u}'
    set LOCAL (git rev-parse @)
    set REMOTE (git rev-parse "$UPSTREAM")
    set BASE (git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]
        echo Up-to-date
        false
    else if [ $LOCAL = $BASE ]
        echo "Need to pull"
        true
    else if [ $REMOTE = $BASE ]
        echo "Need to push"
        false
    else
        echo Diverged
        false
    end
end
