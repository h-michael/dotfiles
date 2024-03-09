function is_linux {
  case $(uname) in
  Linux)
     return 0
     ;;
  *)
     return 1
     ;;
  esac
}

function is_mac {
  case $(uname) in
  Darwin)
     return 0
     ;;
  *)
     return 1
     ;;
  esac
}

function pp_path {
  tr ':' '\n' <<< "$PATH"
}
