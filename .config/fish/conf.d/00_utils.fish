function is_linux
  switch (uname)
    case Linux
      return 0
    case '*'
      return 1
  end
end

function is_mac
  switch (uname)
    case Darwin
      return 0
    case '*'
      return 1
  end
end
