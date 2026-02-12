.PHONY: switch build test update clean nix-gc help setup news diff

# Host auto-detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  HOST := darwin
else ifeq ($(shell test -f /etc/NIXOS && echo yes),yes)
  HOST := nix
else
  HOST := arch
endif

# Default target
help:
	@echo "Auto-detected Commands (current host: $(HOST)):"
	@echo "  make switch         - Rebuild and switch configuration"
	@echo "  make build          - Build without switching"
	@echo "  make test           - Test configuration (dry-run)"
	@echo "  make diff           - Show package changes (requires nvd)"
	@echo ""
	@echo "Platform-specific Commands:"
	@echo "  make switch-nix     - Rebuild and switch NixOS configuration"
	@echo "  make build-nix      - Build without switching"
	@echo "  make test-nix       - Test configuration (dry-run)"
	@echo "  make switch-darwin  - Rebuild and switch nix-darwin configuration"
	@echo "  make build-darwin   - Build nix-darwin without switching"
	@echo "  make test-darwin    - Test configuration (dry-run)"
	@echo "  make switch-arch    - Switch Home Manager on Arch"
	@echo "  make build-arch     - Build Home Manager on Arch"
	@echo "  make test-arch      - Test configuration (dry-run) on Arch"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Install git hooks (lefthook)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update         - Update flake inputs"
	@echo "  make clean          - Remove old generations"
	@echo "  make nix-gc         - Garbage collect nix store"
	@echo "                      - Or keep latest NixOS generations (KEEP=15)"
	@echo "  make news           - Show home-manager news"

# Auto-detect targets
switch: switch-$(HOST)
build: build-$(HOST)
test: test-$(HOST)
diff: diff-$(HOST)

# NixOS commands (--impure needed for gitignored hardware-configuration.nix)
switch-nix:
	sudo nixos-rebuild switch --flake .#nixos

build-nix:
	nixos-rebuild build --flake .#nixos

test-nix:
	nixos-rebuild dry-activate --flake .#nixos

# Arch Linux commands
switch-arch:
	nix run .#homeConfigurations.arch.activationPackage

build-arch:
	nix build .#homeConfigurations.arch.activationPackage

test-arch:
	nix build .#homeConfigurations.arch.activationPackage --dry-run

# macOS commands - nix-darwin + standalone home-manager
# Requires: export DARWIN_USERNAME=yourusername
switch-darwin: switch-darwin-system switch-darwin-home

switch-darwin-system:
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		sudo DARWIN_USERNAME="$$DARWIN_USERNAME" darwin-rebuild switch --flake .#darwin --impure ; \
	else \
		sudo DARWIN_USERNAME="$$DARWIN_USERNAME" nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#darwin --impure ; \
	fi

switch-darwin-home:
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake .#darwin --impure ; \
	else \
		nix run home-manager/release-25.11 -- switch --flake .#darwin --impure ; \
	fi

build-darwin:
	nix build .#darwinConfigurations.darwin.system --impure -o result-system
	nix build .#homeConfigurations.darwin.activationPackage --impure -o result-home

test-darwin:
	nix build .#darwinConfigurations.darwin.system --dry-run --impure
	nix build .#homeConfigurations.darwin.activationPackage --dry-run --impure

# Maintenance
update:
	nix flake update

clean:
	sudo nix-collect-garbage -d

nix-gc:
	@if [ -n "$(KEEP)" ]; then \
		if [ ! -f /etc/NIXOS ]; then \
			echo "nix-gc KEEP is for NixOS system generations only"; \
			exit 1; \
		fi; \
		echo "Keeping latest $(KEEP) NixOS system generations..."; \
		sudo nix-env --list-generations --profile /nix/var/nix/profiles/system \
			| awk '{print $$1}' \
			| head -n -$(KEEP) \
			| xargs -r sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations; \
		sudo nix-collect-garbage -d; \
	else \
		nix store gc; \
	fi

# Setup
setup:
	lefthook install
	@echo "Git hooks installed successfully"

# Home Manager news (auto-detect platform)
news:
	@case "$$(uname -s)" in \
		Darwin) home-manager --flake .#darwin --impure news ;; \
		Linux) \
			if [ -f /etc/NIXOS ]; then \
				home-manager --flake .#nixos --impure news ; \
			else \
				home-manager --flake .#arch --impure news ; \
			fi ;; \
	esac

# Diff commands (requires nvd)
diff-darwin: build-darwin
	@echo "=== System differences ==="
	@nvd diff /run/current-system ./result-system
	@echo ""
	@echo "=== Home Manager differences ==="
	@nvd diff $$(readlink -f ~/.local/state/nix/profiles/home-manager) ./result-home

diff-nix: build-nix
	@nvd diff /run/current-system ./result

diff-arch: build-arch
	@nvd diff $$(readlink -f ~/.local/state/nix/profiles/home-manager) ./result
