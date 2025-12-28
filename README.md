# dotfiles

NixOS and Home Manager configuration managed with Nix Flakes.

## Supported Platforms

- **NixOS** (x86_64-linux)
- **Arch Linux** (x86_64-linux) - via standalone Home Manager
- **macOS** (aarch64-darwin) - via standalone Home Manager

## Commands

```bash
# NixOS
make switch-nix    # Rebuild and switch
make build-nix     # Build only
make test-nix      # Dry-run

# Arch Linux
make switch-arch   # Switch home-manager
make build-arch    # Build only
make test-arch     # Dry-run

# macOS
make switch-darwin # Switch home-manager
make build-darwin  # Build only
make test-darwin   # Dry-run

# Maintenance
make update        # Update flake inputs
make clean         # Remove old generations
make gc            # Garbage collect nix store
```
