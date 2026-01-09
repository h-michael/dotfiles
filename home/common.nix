{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Cross-platform modules
  imports = [
    ../modules/fish
    ../modules/starship
    ../modules/git
    ../modules/tmux
    ../modules/nvim
    ../modules/ghostty
    ../modules/ripgrep
    ../modules/mise
    ../modules/scripts
    ../modules/fastfetch
  ];

  home.stateVersion = "24.05";

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
  };

  home.packages = with pkgs; [
    # Core utilities
    ripgrep
    fd
    fzf
    bat
    eza
    delta
    jq
    yq
    ghq
    tree-sitter
    pstree
    gawk
    fastfetch

    # Development tools
    home-manager
    gh
    gnumake
    pkg-config
    openssl.dev
    direnv
    lefthook
    gitleaks
    git-cliff
    pinact
    ast-grep
    stylua
    nixfmt-rfc-style
    nvd # Nix package version diff
    python3
    ruby
    uv
    deno

    # Kubernetes
    kubectl
    kustomize
    kubectx # includes kubens

    # Protobuf
    buf

    # Language Servers
    lua-language-server
    gopls
    pyright
    typescript-language-server
    yaml-language-server
    terraform-ls
    taplo
    rustup # Rust toolchain manager (removed rust-analyzer to avoid conflict)
    vscode-langservers-extracted # html, css, json, eslint
    omnisharp-roslyn # C# (Unity)
  ];
}
