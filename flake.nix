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
    disko.url = "github:nix-community/disko";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-secrets = {
      url = "git+ssh://git@github.com/NickRI/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
   baseContext = { inherit inputs nixpkgs nixpkgs-unstable home-manager; };
  in
  {
    nixosConfigurations = {
      work-laptop = import ./work-laptop baseContext;
      nas-server = import ./nas-server baseContext;
    };
  };
}
