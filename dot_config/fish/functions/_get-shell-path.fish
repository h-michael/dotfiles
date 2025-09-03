function _get-shell-path -a shell -d "Get shell executable path by name"
  switch "$shell"
    case bash
      echo "/bin/bash"
    case zsh
      echo "/bin/zsh"
    case fish
      echo "/usr/bin/fish"
    case sh
      echo "/bin/sh"
    case ""
      echo "/bin/sh"
    case "*"
      echo "/bin/sh"
  end
end