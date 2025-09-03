function frmrepo -d "Remove selected git repository"
  ghq list --full-path | fzf --multi | xargs rm -rf
end