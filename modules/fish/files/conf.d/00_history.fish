function history-merge --on-event fish_preexec -d "Merge history across fish sessions"
    history --save
    history --merge
end
