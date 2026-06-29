final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "705fbf92eec703cef6f23c1cdbb2c0d822eed7da";
    hash = "sha256-Ehwc5ruNNAwXitaC2oGWtFfssMcZjf8yCo8rJRsmVLw=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
  });
}
