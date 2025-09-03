function fkill -d "Kill selected process"
  ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -9
end