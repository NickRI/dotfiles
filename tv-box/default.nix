{
  inputs,
  nixpkgs,
  home-manager,
  hardware,
  ...
}:

nixpkgs.lib.nixosSystem {
  inherit (hardware) system;
  specialArgs = {
    nixos-hardware = inputs.nixos-hardware;
    grub-themes = inputs.nixos-grub-themes;
    sops-secrets = inputs.sops-secrets;
  };

  modules = [
    home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    hardware.platformModule
    ./system/configuration.nix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.tv = import ./home;

      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.flatpaks.homeManagerModules.nix-flatpak
      ];

      # Optionally, use home-manager.extraSpecialArgs to pass
      # arguments to home.nix
      home-manager.extraSpecialArgs = {
        sops-secrets = inputs.sops-secrets;
      };
    }
  ];
}
