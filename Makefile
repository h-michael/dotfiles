.PHONY: switch build test update clean gc help darwin-switch darwin-build arch-switch arch-build setup

# Default target
help:
	@echo "NixOS Commands:"
	@echo "  make switch-nix     - Rebuild and switch NixOS configuration"
	@echo "  make build-nix      - Build without switching"
	@echo "  make test-nix       - Test configuration (dry-run)"
	@echo ""
	@echo "Arch Linux Commands:"
	@echo "  make switch-arch    - Switch Home Manager on Arch"
	@echo "  make build-arch     - Build Home Manager on Arch"
	@echo "  make test-arch      - Test configuration (dry-run) on Arch"
	@echo ""
	@echo "macOS Commands:"
	@echo "  make switch-darwin  - Switch Home Manager on macOS"
	@echo "  make build-darwin   - Build Home Manager on macOS"
	@echo "  make test-darwin    - Test configuration (dry-run) on macOS"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Install git hooks (lefthook + git-secrets)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update         - Update flake inputs"
	@echo "  make clean          - Remove old generations"
	@echo "  make gc             - Garbage collect nix store"

# NixOS commands (--impure needed for gitignored hardware-configuration.nix)
switch-nix:
	sudo nixos-rebuild switch --flake .#nixos

build-nix:
	nixos-rebuild build --flake .#nixos

test-nix:
	nixos-rebuild dry-activate --flake .#nixos

# Arch Linux commands
switch-arch:
	home-manager switch --flake .#arch

build-arch:
	home-manager build --flake .#arch

test-arch:
	nixos-rebuild dry-activate --flake .#arch

# macOS commands (--impure needed for builtins.getEnv)
switch-darwin:
	home-manager switch --flake .#darwin --impure

build-darwin:
	home-manager build --flake .#darwin --impure

test-darwin:
	nixos-rebuild dry-activate --flake .#darwin --impure

# Maintenance
update:
	nix flake update

clean:
	sudo nix-collect-garbage -d

gc:
	nix store gc

# Setup
setup:
	lefthook install
	git secrets --register-aws
	@echo "Git hooks installed successfully"
