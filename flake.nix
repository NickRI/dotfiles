{
  description = "NixOS personal configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/main";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, ... }:
    let
        lib = nixpkgs.lib;
        system = "x86_64-linux";
        pkgs =  import nixpkgs {
          system = system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "mailspring-1.11.0"
            ];
          };
        };
        unstable = import nixpkgs-unstable {
          system = system;
          config = {
            allowUnfree = true;
          };
        };
    in {
      nixosConfigurations = {
        nick-localhost = lib.nixosSystem {
          inherit system;
          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            ./configuration.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nikolai = import ./home;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = { unstable = unstable; };
            }
          ];
        };
      };
      homeConfigurations = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        nikolai = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./home
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { unstable = unstable; };
        };
      };
    };
}
