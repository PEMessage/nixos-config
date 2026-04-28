{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      overlay = [
        (final: prev: rec {
          neovim = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.neovim;
        })
      ];
      overrideModule = {
        nixpkgs.overlays = overlay;
        nixpkgs.config.allowUnfree = true;
      };
      commonModule = { config, pkgs, ... }: {
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        environment.systemPackages = with pkgs; [
          git
          vim
          tmux
          python3
          zsh
          wget
          curl
          neovim

          # build
          gcc
          gnumake
          cmake
          pkg-config
        ];

        imports = [
          home-manager.nixosModules.home-manager
        ];

        # Could not start dynamically linked executable: tree-sitter
        # NixOS cannot run dynamically linked executables intended for generic
        # linux environments out of the box. For more information, see:
        # https://nix.dev/permalink/stub-ld
        programs.nix-ld.enable = true;

        home-manager =  {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.pem = import ./users/pem/home-manager.nix {
            inputs = inputs;
          };
        };
      };
    in {
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit (inputs) nixos-wsl; };
        modules = [
          overrideModule
          commonModule
          ./machines/wsl.nix
        ];
      };
    };
}
