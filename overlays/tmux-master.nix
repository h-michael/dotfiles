final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "7713cbebd21a37b52cf90766c655075172c2a549";
    hash = "sha256-cRtL1cgac0nCeY23LFCtiaxkUwPTRpx5TPkPFJ2McT8=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
  });
}
