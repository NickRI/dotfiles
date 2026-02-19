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
      home-manager.users.nas = import ./home;

      # Optionally, use home-manager.extraSpecialArgs to pass
      # arguments to home.nix
      home-manager.extraSpecialArgs = { };
    }
  ];
}
