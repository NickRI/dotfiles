{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  hardware,
  ...
}:
let
  pkgs = import nixpkgs {
    inherit (hardware) system;
    config.allowUnfree = true;
  };
  unstable = import nixpkgs-unstable {
    inherit (hardware) system;
    config.allowUnfree = true;
  };
  overlay-unstable = final: prev: { inherit unstable; };
  overlay-opencode = final: _: {
    opencode = (
      inputs.opencode.packages.${final.stdenv.hostPlatform.system}.opencode.override {
        node_modules = final.callPackage (inputs.opencode.outPath + "/nix/node_modules.nix") {
          rev = inputs.opencode.shortRev or "unknown";
          hash = "sha256-BGIeB3pTxfR0DM5H/Bs0RXw4tO/Jdjum93tOAPcH91I=";
        };
      }
    );
  };
in
nixpkgs.lib.nixosSystem {
  inherit (hardware) system;
  specialArgs = {
    nixos-hardware = inputs.nixos-hardware;
    sops-secrets = inputs.sops-secrets;
  };

  modules = [
    (
      { ... }:
      {
        nixpkgs.pkgs = pkgs;
        nixpkgs.overlays = [
          overlay-unstable
          overlay-opencode
        ];
      }
    )
    home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.ancaeus.nixosModules.default
    hardware.platformModule
    ./system/configuration.nix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.nikolai = import ./home;

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
