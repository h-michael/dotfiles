function gpr
  set PR_NUM $argv[1]
  set BRANCH_NAME $argv[2]
  git fetch upstream pull/$PR_NUM/merge:$BRANCH_NAME
  git checkout $BRANCH_NAME
end
