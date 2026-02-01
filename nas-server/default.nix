{
  inputs,
  nixpkgs,
  home-manager,
  ...
}:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    sops-secrets = inputs.sops-secrets;
  };

  modules = [
    home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ../shared/platforms/zimablade-7700.nix
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
