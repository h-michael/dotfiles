final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "dd62c2f9467f975388f4a2701022752961bdb086";
    hash = "sha256-4PK44+K5IuV8v/cw+HvZHfqzZEEvelG/Bm5HNL/ozNY=";
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
