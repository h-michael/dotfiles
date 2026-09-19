# dotfiles

NixOS and Home Manager configuration managed with Nix Flakes.

## Supported Platforms

- **NixOS** (x86_64-linux)
- **Arch Linux** (x86_64-linux) - via standalone Home Manager
- **macOS** (aarch64-darwin) - via standalone Home Manager

## Commands

```bash
# NixOS
make switch NIXOS_HOST=ms-s1-max  # Rebuild and switch
make build  NIXOS_HOST=ms-s1-max  # Build only
make test   NIXOS_HOST=ms-s1-max  # Dry-run

make switch NIXOS_HOST=t495s      # Rebuild and switch
make build  NIXOS_HOST=t495s      # Build only
make test   NIXOS_HOST=t495s      # Dry-run

# Arch Linux
make switch  # Switch home-manager
make build   # Build only
make test    # Dry-run

# macOS
make switch  # Switch nix-darwin + home-manager
make build   # Build only
make test    # Dry-run

# Maintenance
make update        # Update flake inputs
make clean         # Remove old generations
make gc            # Garbage collect nix store
```
