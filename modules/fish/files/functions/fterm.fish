function fterm -d "Terminate selected process gracefully"
    set -l pids (ps -ef | sed 1d | fzf -m --prompt="Select processes to terminate: " | awk '{print $2}')
    if test -z "$pids"
        return 0
    end

    echo "Selected processes:"
    printf "%s\n" $pids | while read -l pid
        ps -p $pid -o pid,comm,args 2>/dev/null | tail -n 1
    end
    echo ""
    read -l -P "Terminate these processes with -15 (SIGTERM)? [y/N] " confirm
    if test "$confirm" = y -o "$confirm" = Y
        printf "%s\n" $pids | xargs kill -15
    else
        echo Cancelled
    end
end
