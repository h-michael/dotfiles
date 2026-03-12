final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "04b4952f0e761818c8fb75c1267e85f688c17498";
    hash = "sha256-KuP16gv9qaXpFtm4hwZls/7FZDC6fmPezryhPyHGNM4=";
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
