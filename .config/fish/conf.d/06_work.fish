function obct2utc
  set t (math 1514764800 + $argv[1])
  if is_linux
    date -d "@"$t
  end
  if is_mac
    date -r $t
  end
end
