{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-wsl = { 
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    commonModule = { config, pkgs, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      
      environment.systemPackages = with pkgs; [ 
        git
        vim
        tmux
      ];
      imports = [
        home-manager.nixosModules.home-manager
      ];

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
        commonModule
        ./machines/wsl.nix
      ];
    };
  };
}
