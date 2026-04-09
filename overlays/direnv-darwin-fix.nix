# direnv 2.37.1 fish test hangs/crashes on macOS (Killed: 9)
# TODO: Remove when upstream nixpkgs fixes this
final: prev: {
  direnv = prev.direnv.overrideAttrs (old: {
    doCheck = false;
  });
}
