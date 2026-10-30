function fgc -d "git checkout selected branch"
    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    set -l merged_branches (git for-each-ref --merged $default_branch --format='%(refname:short)' refs/heads 2>/dev/null)
    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)
    set -l branches
    set -l names
    set -l worktrees
    git for-each-ref --format='%(refname:short)%09%(worktreepath)' refs/heads | while read -l -d \t b wt
        set -l name $b
        if test "$b" != "$default_branch"; and contains $b $merged_branches
            set name "$name [merged]"
        end
        set -a branches $b
        set -a names $name
        set -a worktrees "$wt"
    end
    set -l width (string length --visible -- $names | sort -n | tail -1)

    set -l i 0
    set -l branch (for b in $branches
        set i (math $i + 1)
        set -l label $names[$i]
        set -l wt $worktrees[$i]
        set -l locked 0
        if test -n "$wt"
            set -l wt_label "("(string replace -r '^'(string escape --style=regex $HOME) '~' $wt)")"
            # git refuses to check out a branch that another worktree holds
            if test "$wt" != "$toplevel"
                set locked 1
                set wt_label (set_color yellow)$wt_label(set_color normal)
            end
            set label (string pad -r -w $width -- $label)" $wt_label"
        end
        printf '%s\t%s\t%s\n' $b $label $locked
    end | fzf --reverse --ansi --prompt="Select branch: " --delimiter=\t --with-nth=2 \
        --bind 'enter:transform:test {3} = 1 && echo "change-header:Checked out in another worktree" || echo accept' \
        --bind 'double-click:transform:test {3} = 1 && echo "change-header:Checked out in another worktree" || echo accept' \
        | cut -f1)

    if test -n "$branch"
        git checkout $branch
    end
end
