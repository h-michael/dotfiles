# strip -S invalidates ad-hoc code signature on macOS arm64
# Re-sign after fixup to prevent SIGKILL from macOS kernel
# TODO: Remove when nixpkgs Darwin stdenv re-signs after stripping
final: prev: {
  fish = prev.fish.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      for f in $out/bin/*; do
        if [ -f "$f" ] && [ -x "$f" ]; then
          /usr/bin/codesign -f -s - "$f"
        fi
      done
    '';
  });
}
