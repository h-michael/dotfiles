function init-ssh-agent -d "Ensure a reachable ssh-agent and load keys"
    # ssh-add -l exits 2 when no agent is reachable. An agent the session
    # already has (launchd's on macOS, a forwarded one over SSH) is used
    # as is instead of being replaced.
    ssh-add -l >/dev/null 2>&1
    if test $status -eq 2
        # XDG_RUNTIME_DIR is per-user with mode 0700, unlike /tmp, so no
        # other user can plant the file sourced here.
        set -q XDG_RUNTIME_DIR; or return
        set -l agent_env $XDG_RUNTIME_DIR/ssh-agent-env.fish

        test -f $agent_env; and source $agent_env
        ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            ssh-agent -c | sed \
                -e '/^echo /d' \
                -e 's/^setenv/set -gx/' \
                -e 's/;//g' >$agent_env
            source $agent_env
        end
    end

    # Load keys only once per agent
    if not ssh-add -l >/dev/null 2>&1
        ssh-add
    end
end
