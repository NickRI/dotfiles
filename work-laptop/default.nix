{ inputs, nixpkgs, nixpkgs-unstable, home-manager, ... }:
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
  in nixpkgs.lib.nixosSystem {
    inherit system;
    inherit pkgs;

    specialArgs = {
      nixos-hardware = inputs.nixos-hardware;
      grub-themes = inputs.nixos-grub-themes;
    };

    modules = [
      ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
      home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      ./system/configuration.nix
      ../platforms/framework-13-intel-13-gen.nix
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nikolai = import ./home;

        # Optionally, use home-manager.extraSpecialArgs to pass
        # arguments to home.nix
        home-manager.extraSpecialArgs = { flatpaks = inputs.flatpaks; };
      }
    ];
  }