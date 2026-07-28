final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "9c402fa7b70c5328ea183fa2f18a7eaf44c0857d";
    hash = "sha256-HPZKyISkvi8oR+AjeRyD0RdR4fvqqEiRg42o7GuZ39Y=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
    # nixpkgs' tmux-control-notify-uninitialized.patch backports a fix that
    # is already present on this master revision, so applying it fails.
    patches = [ ];
    # versionCheckHook expects `tmux -V` to report the `version` attribute
    # above, but the binary reports its own git-describe string instead.
    doInstallCheck = false;
    # This master revision requires an explicit jemalloc choice on macOS,
    # to work around a calloc(3) zeroing bug in the system allocator.
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-jemalloc" ];
    buildInputs = oldAttrs.buildInputs ++ [ final.jemalloc ];
  });
}
