final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "d7f59eccaf7f9435065017fa214a7b3c53bc631d";
    hash = "sha256-+dLXSVPZezGuJPsTAbp6eyhQFSa3AZrdQwEvJHq6GXw=";
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
