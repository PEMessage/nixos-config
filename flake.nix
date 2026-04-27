{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-wsl = { 
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let
    commonModule = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [ 
        git
        vim
      ];
    };
  in {
    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit (inputs) nixos-wsl; };
      modules = [
        commonModule
        ./machines/wsl.nix
      ];
    };
  };
}
