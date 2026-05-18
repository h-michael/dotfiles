final: prev:
let
  tmuxMasterSrc = prev.fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "18ddda48d2e4cc401ae0ea018f175d38a90c9699";
    hash = "sha256-9Mwe8DxNGUCwrcZBW5A1uydzRNrMP1uikRdEq38Kkb8=";
  };
in
{
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = tmuxMasterSrc;
  });
}
