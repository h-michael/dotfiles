final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "e880cf63e0a9fe095d7c5d313761520fb1a8653c";
    hash = "sha256-ODpffQUf7obGWS7Cl/4KxNJGkvKNI9w5+/Jf2vNXJEU=";
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
