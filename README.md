# dotfiles

NixOS and Home Manager configuration managed with Nix Flakes.

## Supported Platforms

- **NixOS** (x86_64-linux)
- **macOS** (aarch64-darwin) - nix-darwin + standalone Home Manager

## Commands

```bash
# NixOS
make switch NIXOS_HOST=ms-s1-max  # Rebuild and switch
make build  NIXOS_HOST=ms-s1-max  # Build only
make test   NIXOS_HOST=ms-s1-max  # Dry-run

make switch NIXOS_HOST=t495s      # Rebuild and switch
make build  NIXOS_HOST=t495s      # Build only
make test   NIXOS_HOST=t495s      # Dry-run

# macOS
make switch  # Switch nix-darwin + home-manager
make build   # Build only
make test    # Dry-run

# Setup (once per clone)
make setup         # Install git hooks (gitleaks, formatters)

# Maintenance
make update            # Update flake inputs
make clean             # Remove old generations
make nix-gc            # Garbage collect nix store (NixOS: KEEP=N keeps N generations)
make nix-gc OLDER=14d  # Remove system and user generations older than 14 days, then collect
```

Neovim plugins are pinned by `modules/nvim/lazy-lock.json`. Update them with `:Lazy update` and commit the lockfile diff.
