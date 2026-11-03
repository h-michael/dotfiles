{
  description = "h-michael's NixOS and dotfiles managed with Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
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
      # Single overlay list for every pkgs instance, so no configuration
      # silently misses one.
      sharedOverlays = [
        self.overlays.unstable
        self.overlays.uhk-agent-fix
        self.overlays.tmux-master
        self.overlays.custom-packages
        self.overlays.vscode-langservers-fix
        self.overlays.neovim-unstable
      ];

      # Unstable packages for NixOS services (Ollama, Open WebUI, Navidrome)
      nixosUnstablePkgs = import nixpkgs-unstable {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
        overlays = [
          (final: prev: {
            python3Packages = prev.python3Packages.overrideScope (
              pyFinal: pyPrev: {
                # Open WebUI 0.12.3 requires MCP 1.x; MCP 2.x removed
                # streamablehttp_client and prevents the service from starting.
                mcp =
                  (prev.lib.callPackageWith (
                    pyPrev
                    // {
                      inherit (prev) fetchFromGitHub lib stdenv;
                    }
                  ) "${nixpkgs}/pkgs/development/python-modules/mcp" { }).overridePythonAttrs
                    (_: {
                      # MCP 1.x tests are incompatible with pytest 9.x.
                      doCheck = false;
                    });

                # PostHog's MCP integration test expects the pre-2.x API.
                # ChromaDB only needs its runtime package for Open WebUI.
                posthog = pyPrev.posthog.overridePythonAttrs (old: {
                  doCheck = false;
                  meta = old.meta // {
                    broken = false;
                  };
                });
              }
            );
          })
        ];
      };
      mkNixosHost =
        hostPath:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            hostPath

            # xremap as a NixOS module (replaces hand-rolled user systemd
            # services for Hyprland/niri/KDE binaries; configured in the
            # host module via services.xremap)
            inputs.xremap-flake.nixosModules.default

            { nixpkgs.overlays = sharedOverlays; }

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
              };
            }
          ];
        };
    in
    {
      # Overlays
      overlays = {
        # pkgs.unstable: one nixpkgs-unstable instance per pkgs, inheriting
        # its config so the unfree policy is decided in one place.
        unstable = final: prev: {
          unstable = import nixpkgs-unstable {
            inherit (final.stdenv.hostPlatform) system;
            inherit (final) config;
          };
        };
        uhk-agent-fix = import ./overlays/uhk-agent-fix.nix;
        tmux-master = import ./overlays/tmux-master.nix;
        vscode-langservers-fix = import ./overlays/vscode-langservers-fix.nix;
        custom-packages = final: prev: {
          cica-font = final.callPackage ./pkgs/cica-font.nix { };
          lazy-tmux = final.callPackage ./pkgs/lazy-tmux.nix { };
        };
        # As of 2026-10, nixos-26.05 had no Neovim backports after 0.12.4,
        # while unstable picks up each release within days and is still
        # served from cache.nixos.org.
        neovim-unstable = final: prev: {
          neovim-unwrapped = final.unstable.neovim-unwrapped;
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        ms-s1-max = mkNixosHost ./hosts/ms-s1-max;
        t495s = mkNixosHost ./hosts/t495s;
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

          { nixpkgs.overlays = sharedOverlays; }
        ];
      };

      # Standalone Home Manager for macOS
      homeConfigurations = {
        # macOS (Apple Silicon)
        darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            overlays = sharedOverlays;
            # copilot-language-server carries an unfree license; scope the
            # exception to just that package rather than allowing unfree
            # broadly.
            config.allowUnfreePredicate = pkg: pkg.pname or "" == "copilot-language-server";
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./home/darwin.nix
            {
              home.username = darwinUsername;
              home.homeDirectory = "/Users/${darwinUsername}";
            }
          ];
        };
      };

      # Formatter for `nix fmt`
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # Development shell
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            nil
            nixfmt
          ];
        };
      });
    };
}
