final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "31d77e29b6c9fbb07d032018da78db3a8a38d979";
    hash = "sha256-7Sc1KAVs0eSkTkbkGf/fN3ploC8ZOc4RgZPF+NoyGnQ=";
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
