{
  description = "h-michael's NixOS and dotfiles managed with Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-copy-pane = {
      url = "github:h-michael/tmux-copy-pane";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      darwin,
      neovim-nightly-overlay,
      tmux-copy-pane,
      ...
    }@inputs:
    let
      # Linux username
      username = "h-michael";
      # macOS username (from environment variable, requires --impure)
      darwinUsername =
        let
          envUser = builtins.getEnv "DARWIN_USERNAME";
        in
        if envUser != "" then
          envUser
        else
          throw "DARWIN_USERNAME environment variable is required. Set it before running.";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      # Unstable packages for NixOS services (Ollama, Open WebUI, Navidrome)
      nixosUnstablePkgs = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ ];
      };
    in
    {
      # Overlays
      overlays = {
        uhk-agent-fix = import ./overlays/uhk-agent-fix.nix;
        tmux-master = import ./overlays/tmux-master.nix;
        custom-packages = final: prev: {
          cica-font = final.callPackage ./pkgs/cica-font.nix { };
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs username;
            unstablePkgs = nixosUnstablePkgs;
          };
          modules = [
            ./hosts/nixos

            # xremap as a NixOS module (replaces hand-rolled user systemd
            # services for Hyprland/niri/KDE binaries; configured in
            # hosts/nixos/default.nix via services.xremap)
            inputs.xremap-flake.nixosModules.default

            # Apply overlays
            {
              nixpkgs.overlays = [
                self.overlays.uhk-agent-fix
                self.overlays.tmux-master
                self.overlays.custom-packages
                neovim-nightly-overlay.overlays.default
              ];
            }

            # Home Manager as NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Plasma writes files like ~/.gtkrc-2.0 on session start that
              # then collide with home-manager's managed copies. Auto-backup
              # rather than aborting activation, and silently replace any
              # stale backup left from a previous activation cycle.
              home-manager.backupFileExtension = "hm-backup";
              home-manager.overwriteBackup = true;
              home-manager.users.${username} = import ./home/linux.nix;
              home-manager.sharedModules = [
                inputs.plasma-manager.homeModules.plasma-manager
              ];
              home-manager.extraSpecialArgs = {
                inherit inputs username;
                isNixOS = true;
              };
            }
          ];
        };
      };

      # nix-darwin configurations for macOS (system only, home-manager is standalone)
      darwinConfigurations.darwin = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
          username = darwinUsername;
        };
        modules = [
          ./hosts/darwin

          # Apply overlays
          {
            nixpkgs.overlays = [
              self.overlays.tmux-master
              self.overlays.custom-packages
              neovim-nightly-overlay.overlays.default
            ];
          }
        ];
      };

      # Standalone Home Manager for non-NixOS systems
      homeConfigurations = {
        # macOS (Apple Silicon)
        darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            overlays = [
              self.overlays.tmux-master
              self.overlays.custom-packages
              neovim-nightly-overlay.overlays.default
              (import ./overlays/inetutils-macos-fix.nix)
              (import ./overlays/direnv-darwin-fix.nix)
              (import ./overlays/fish-darwin-codesign-fix.nix)
            ];
          };
          extraSpecialArgs = {
            inherit inputs;
            isNixOS = false;
          };
          modules = [
            ./home/darwin.nix
            {
              home.username = darwinUsername;
              home.homeDirectory = "/Users/${darwinUsername}";
            }
          ];
        };

        # Arch Linux (or other non-NixOS Linux)
        arch = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs username;
            isNixOS = false;
          };
          modules = [
            ./home/linux.nix
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              targets.genericLinux.enable = true;
            }
          ];
        };
      };

      # Formatter for `nix fmt`
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # Development shell
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            nil
            nixfmt-rfc-style
          ];
        };
      });
    };
}
