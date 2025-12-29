{
  description = "h-michael's NixOS and dotfiles managed with Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
      ...
    }@inputs:
    let
      username = "h-michael";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      # Unstable packages for latest Ollama and Open WebUI
      unstablePkgs = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      # Overlays
      overlays = {
        uhk-agent-fix = import ./overlays/uhk-agent-fix.nix;
        custom-packages = final: prev: {
          cica-font = final.callPackage ./pkgs/cica-font.nix { };
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs username unstablePkgs; };
          modules = [
            ./hosts/nixos

            # Apply overlays
            {
              nixpkgs.overlays = [
                self.overlays.uhk-agent-fix
                self.overlays.custom-packages
                neovim-nightly-overlay.overlays.default
              ];
            }

            # Home Manager as NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./hosts/home-linux.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs username;
                isNixOS = true;
              };
            }
          ];
        };
      };

      # Standalone Home Manager for non-NixOS systems
      homeConfigurations = {
        # macOS (Apple Silicon)
        # Username and home directory are read from USER/HOME env vars (requires --impure)
        darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit inputs;
            isNixOS = false;
          };
          modules = [
            ./hosts/home-darwin.nix
            {
              home.username = builtins.getEnv "USER";
              home.homeDirectory = builtins.getEnv "HOME";
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
            ./hosts/home-linux.nix
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              targets.genericLinux.enable = true;
            }
          ];
        };
      };

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
