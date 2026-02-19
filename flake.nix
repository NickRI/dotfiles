{
  description = "NixOS personal configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flatpaks.url = "github:gmodena/nix-flatpak/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-grub-themes = {
      url = "github:jeslie0/nixos-grub-themes";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-secrets = {
      url = "git+ssh://git@github.com/NickRI/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }@inputs:
    let
      baseContext = {
        inherit
          inputs
          nixpkgs
          nixpkgs-unstable
          home-manager
          ;
      };

      platforms = builtins.listToAttrs (
        map (fname: {
          name = nixpkgs.lib.strings.removeSuffix ".nix" fname;
          value = ./shared/platforms/${fname};
        }) (builtins.attrNames (builtins.readDir ./shared/platforms))
      );

      mkHost =
        {
          host,
          context,
          platform,
          system ? "x86_64-linux",
        }:

        import host (
          context
          // {
            hardware = {
              system = system;
              platformModule = platforms.${platform};
            };
          }
        );
    in
    {
      nixosConfigurations = {
        work-laptop-amd = mkHost {
          host = ./work-laptop;
          context = baseContext;
          platform = "framework-13-amd-ai-300-series";
        };

        work-laptop-intel = mkHost {
          host = ./work-laptop;
          context = baseContext;
          platform = "framework-13-intel-13-gen";
        };

        nas-server-zimablade = mkHost {
          host = ./nas-server;
          context = baseContext;
          platform = "zimablade-7700";
        };

        tv-box-intel = mkHost {
          host = ./tv-box;
          context = baseContext;
          platform = "framework-13-intel-13-gen";
        };

        tv-box-zimablade = mkHost {
          host = ./tv-box;
          context = baseContext;
          platform = "zimablade-7700";
        };
      };
    };
}
