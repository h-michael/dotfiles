.PHONY: switch build test update clean nix-gc help setup news diff \
	brew-update brew-outdated brew-info brew-upgrade brew-check

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
	@echo "Commands (detected host: $(HOST)):"
	@echo "  make switch         - Rebuild and switch configuration"
	@echo "  make build          - Build without switching"
	@echo "  make test           - Test configuration (dry-run)"
	@echo "  make diff           - Show package changes (requires nvd)"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Install git hooks (lefthook)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update         - Update flake inputs"
	@echo "  make clean          - Remove old generations"
	@echo "  make nix-gc         - Garbage collect nix store"
	@echo "                        Or keep latest NixOS generations (KEEP=15)"
	@echo "  make news           - Show home-manager news"
ifeq ($(HOST),darwin)
	@echo ""
	@echo "Homebrew (cask audit workflow):"
	@echo "  make brew-check     - Refresh tap metadata, then list outdated casks"
	@echo "  make brew-update    - brew update (refresh tap metadata only)"
	@echo "  make brew-outdated  - brew outdated --cask --verbose"
	@echo "  make brew-info CASK=<name>    - brew info --cask <name>"
	@echo "  make brew-upgrade CASK=<name> - brew upgrade --cask <name>"
endif

# Main targets with inlined platform logic
ifeq ($(HOST),darwin)

switch:
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		sudo DARWIN_USERNAME="$$DARWIN_USERNAME" darwin-rebuild switch --flake .#darwin --impure ; \
	else \
		sudo DARWIN_USERNAME="$$DARWIN_USERNAME" nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#darwin --impure ; \
	fi
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake .#darwin --impure ; \
	else \
		nix run home-manager/release-25.11 -- switch --flake .#darwin --impure ; \
	fi

build:
	nix build .#darwinConfigurations.darwin.system --impure -o result-system
	nix build .#homeConfigurations.darwin.activationPackage --impure -o result-home

test:
	nix build .#darwinConfigurations.darwin.system --dry-run --impure
	nix build .#homeConfigurations.darwin.activationPackage --dry-run --impure

diff: build
	@echo "=== System differences ==="
	@nvd diff /run/current-system ./result-system
	@echo ""
	@echo "=== Home Manager differences ==="
	@nvd diff $$(readlink -f ~/.local/state/nix/profiles/home-manager) ./result-home

# Homebrew cask audit workflow
brew-update:
	brew update

brew-outdated:
	brew outdated --cask --verbose

brew-check: brew-update brew-outdated

brew-info:
	@test -n "$(CASK)" || { echo "Usage: make brew-info CASK=<name>"; exit 1; }
	brew info --cask $(CASK)

brew-upgrade:
	@test -n "$(CASK)" || { echo "Usage: make brew-upgrade CASK=<name>"; exit 1; }
	brew upgrade --cask $(CASK)

else ifeq ($(HOST),nix)

switch:
	sudo nixos-rebuild switch --flake .#nixos

build:
	nixos-rebuild build --flake .#nixos

test:
	nixos-rebuild dry-activate --flake .#nixos

diff: build
	@nvd diff /run/current-system ./result

else # arch

switch:
	nix run .#homeConfigurations.arch.activationPackage

build:
	nix build .#homeConfigurations.arch.activationPackage

test:
	nix build .#homeConfigurations.arch.activationPackage --dry-run

diff: build
	@nvd diff $$(readlink -f ~/.local/state/nix/profiles/home-manager) ./result

endif

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

# Home Manager news
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
