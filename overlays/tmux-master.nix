final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "fcce73af4224fd7e172936f402f8d398ae4fa1d9";
    hash = "sha256-kPAzVVNBx3GTE6U2NL91tWkjbqQyiR1TEvpgXIfQXUY=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
  });
}
