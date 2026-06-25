final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "6e6a434a2d64a29855e071511d04f2d26ecf5ca5";
    hash = "sha256-hIOTAKeF/oU4DDhItJRJ7SdTCSI4FqBaavLOhpwT7J0=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
  });
}
