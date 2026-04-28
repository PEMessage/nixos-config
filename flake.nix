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
          # basic
          bc
          python3
          wget
          curl

          # utils
          git
          vim
          tmux
          zsh
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

        programs.zsh.enable = true;
        programs.bash.enable = true;

        # Could not start dynamically linked executable: tree-sitter
        # NixOS cannot run dynamically linked executables intended for generic
        # linux environments out of the box. For more information, see:
        # https://nix.dev/permalink/stub-ld
        programs.nix-ld.enable = true;

        # User zone
        home-manager =  {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.pem = import ./users/pem/home-manager.nix {
            inputs = inputs;
          };
        };
        users.users.pem = {
          isNormalUser = true;
          shell = pkgs.zsh;
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
