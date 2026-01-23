final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "e6522138557e31b60bae8e303453bd3cdea6f978";
    hash = "sha256-EMW5MRHqUWjJ+X36LvundeDQ4L0scQ5KTiaixJq6aiI=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
  });

  tmux-asan = prev.tmux.overrideAttrs (oldAttrs: {
    pname = "tmux-asan";
    version = "git-master";
    src = tmuxMasterSrc;

    configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
      "--disable-optimizations"
    ];

    preConfigure = (oldAttrs.preConfigure or "") + ''
      export CFLAGS="$CFLAGS -fsanitize=address -fno-omit-frame-pointer -g"
      export LDFLAGS="$LDFLAGS -fsanitize=address"
    '';

    postInstall = (oldAttrs.postInstall or "") + ''
      mv $out/bin/tmux $out/bin/tmux-asan
    '';

    hardeningDisable = [ "all" ];
  });
}
