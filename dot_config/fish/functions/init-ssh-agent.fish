function init-ssh-agent -d "Ensure single ssh-agent instance and load keys"
  # Location to store environment file (safely cleared per session)

  set -l AGENT_ENV $TMPDIR/ssh-agent-env.fish

  # Load existing environment file if present
  if test -f $AGENT_ENV
    source $AGENT_ENV
  end

  # Restart agent if not running
  if not set -q SSH_AGENT_PID; or not kill -0 $SSH_AGENT_PID > /dev/null 2>&1
    ssh-agent -c | sed \
      -e '/^echo /d' \
      -e 's/^setenv/set -gx/' \
      -e 's/;//g' > $AGENT_ENV

    source $AGENT_ENV
  end

  # Add key only once if none are registered
  if not ssh-add -l > /dev/null 2>&1

    ssh-add --apple-use-keychain

  end
end