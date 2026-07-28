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
    # nixpkgs' tmux-control-notify-uninitialized.patch backports a fix that
    # is already present on this master revision, so applying it fails.
    patches = [ ];
    # versionCheckHook expects `tmux -V` to report the `version` attribute
    # above, but the binary reports its own git-describe string instead.
    doInstallCheck = false;
  });
}
