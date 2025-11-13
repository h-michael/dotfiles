function fdr -d "Select Docker container and remove the container"
    set -l containers (docker container ls -a -f status=exited --format "{{.ID}}\t{{.Image}}\t{{.Command}}" | fzf -m --prompt="Select containers to remove: " --delimiter="\t" --with-nth=1,2 | cut -f1)
    if test -z "$containers"
        return 0
    end

    echo "Selected containers for removal:"
    printf "%s\n" $containers | while read -l cid
        docker container ls -a --filter "id=$cid" --format "  - {{.ID}} ({{.Image}})"
    end
    echo ""
    read -l -P "Remove these containers? [y/N] " confirm
    if test "$confirm" = y -o "$confirm" = Y
        printf "%s\n" $containers | xargs docker rm
    else
        echo Cancelled
    end
end
