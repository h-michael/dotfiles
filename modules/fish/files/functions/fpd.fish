function fpd -d "Select a process with fzf and show its current working directory"
    set -l line (ps -eo pid,user,etime,command | tail -n +2 | fzf \
        --layout=reverse \
        --border=rounded \
        --no-multi \
        --info=inline \
        --with-nth=2.. \
        --prompt="Select process: ")

    if test -z "$line"
        return 1
    end

    set -l pid (echo "$line" | awk '{print $1}')

    lsof -a -d cwd -p "$pid" | awk 'NR==2{print $NF}'
end
