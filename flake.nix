{
  description = "NixOS personal configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:tmarkov/nix-flatpak/main";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, ... }:
    let
        lib = nixpkgs.lib;
        system = "x86_64-linux";
        pkgs =  import nixpkgs { system = system; config.allowUnfree = true; };
        unstable = import nixpkgs-unstable { system = system; config = {
            allowUnfree = true; permittedInsecurePackages = [ "mailspring-1.11.0" ];
        }; };
    in {
        nixosConfigurations = {
          fedora = lib.nixosSystem {
            inherit system;
            modules = [ ./configuration.nix ];
          };
        };
        homeConfigurations = {
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
            extraSpecialArgs = {unstable = unstable; flatpack = nix-flatpak; };
          };
        };
    };
}