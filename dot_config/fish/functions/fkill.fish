function fkill -d "Kill selected process"
    set -l pids (ps -ef | sed 1d | fzf -m --prompt="Select processes to kill: " | awk '{print $2}')
    if test -z "$pids"
        return 0
    end

    echo "Selected processes:"
    printf "%s\n" $pids | while read -l pid
        ps -p $pid -o pid,comm,args 2>/dev/null | tail -n 1
    end
    echo ""
    read -l -P "Kill these processes with -9 (SIGKILL)? [y/N] " confirm
    if test "$confirm" = y -o "$confirm" = Y
        printf "%s\n" $pids | xargs kill -9
    else
        echo Cancelled
    end
end
