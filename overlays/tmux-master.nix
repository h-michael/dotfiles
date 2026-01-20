final: prev: {
  tmux = prev.tmux.overrideAttrs (oldAttrs: {
    version = "git-master";
    src = prev.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = "bf8ea85bd751beb55f83c117d4b9b99fded0105b";
      hash = "sha256-uDwCaXD20qboC1xfyTAnD1BoqQWTmgLjfpHoW6tUzpk=";
    };
  });
}
