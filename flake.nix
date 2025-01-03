{
  description = "NixOS personal configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flatpaks.url = "github:gmodena/nix-flatpak/main";
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        overlay-unstable = final: prev: { inherit unstable; };
    in {
      nixosConfigurations = {
        framework-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;

          specialArgs = { inherit inputs; };

          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nikolai = import ./home;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = { flatpaks = inputs.flatpaks; };
            }
          ];
        };
      };
    };
}
