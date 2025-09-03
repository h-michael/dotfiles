function gcop -d "Git checkout pull request"
  set PR_NUMBER ""
  set BRANCH_NAME ""
  set REMOTE "upstream"

  if count $argv > /dev/null
  else
    echo 'pull request number and branch name must be given'
    return
  end

  set PR_NUMBER $argv[1]

  if count $argv[2] > /dev/null
    set BRANCH_NAME $argv[2]
  else
    echo 'branch name must be given'
    return
  end

  if count $argv[3] > /dev/null
    set REMOTE $argv[3]
  end

  git fetch $REMOTE pull/$PR_NUMBER/head:$BRANCH_NAME
  git checkout $BRANCH_NAME
end