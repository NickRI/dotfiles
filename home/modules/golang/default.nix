{ config, unstable, pkgs, ... }:
let
    inherit (unstable) fetchFromGitHub;
    #TODO: Wait until vendorHash will be able to change
    minimock = unstable.go-minimock.overrideAttrs(oldAttrs: rec {
        version = "3.3.14";
        vendorHash = "";

        src = fetchFromGitHub {
          owner = oldAttrs.src.owner;
          repo = oldAttrs.src.repo;
          rev = "v${version}";
          sha256 = "sha256-J4clMn65l7L+qSHbJBMDDRoEfgGHKllRu8nvTGlbgaw=";
        };
    });

    go-task = unstable.go-task.overrideAttrs(oldAttrs: rec {
        version = "3.38.0";
        vendorHash = "";

        src = fetchFromGitHub {
          owner = oldAttrs.pname;
          repo = oldAttrs.src.repo;
          rev = "refs/tags/v${version}";
          hash = "sha256-mz/07DONaO3kCxOXEnvWglY0b9JXxCXjTrVIEbsbl98=";
        };
    });

    enumer = unstable.enumer.overrideAttrs(oldAttrs: rec {
        version = "1.5.10";
        vendorHash = "";

        src = fetchFromGitHub {
          owner = oldAttrs.src.owner;
          repo = oldAttrs.src.repo;
          rev = "refs/tags/v${version}";
          hash = "sha256-7tU1etCrgG05HU1N9c1o2S9VNXRONFBCoM317pIddcw=";
        };
    });

    golangci-lint = unstable.golangci-lint.overrideAttrs(oldAttrs: rec {
        version = "1.59.1";
        vendorHash = "";

        src = fetchFromGitHub {
          owner = oldAttrs.src.owner;
          repo = oldAttrs.src.repo;
          rev = "refs/tags/v${version}";
          hash = "sha256-VFU/qGyKBMYr0wtHXyaMjS5fXKAHWe99wDZuSyH8opg=";
        };
    });


    scc = unstable.scc.overrideAttrs(oldAttrs: rec {
        version = "3.3.5";
        vendorHash = "";

        src = fetchFromGitHub {
          owner = oldAttrs.src.owner;
          repo = oldAttrs.src.repo;
          rev = "refs/tags/v${version}";
          hash = "sha256-7qenc/1FEwiyR7qz6u8L35Wb8zAUVQ5sG5bvYpZKdzs=";
        };
    });



    goose = unstable.goose.overrideAttrs(oldAttrs: rec {
        version = "3.21.1";

        checkFlags = [];

        src = fetchFromGitHub {
          owner = oldAttrs.src.owner;
          repo = oldAttrs.src.repo;
          rev = "refs/tags/v${version}";
          hash = "sha256-Klmgw5dYt2/JYc0nuqIZwos3/onlRwsfzTOJ/Yi2pMw=";
        };
    });


in
{
  imports = [
    ./custom-config.nix
  ];

  config = {
    programs.go = {
      enable = true;
      package = unstable.go;
      goBin = "$HOME/go/bin";
      goPrivate = [
        "github.com/wert-io"
      ];
    };

    home.packages = [
      unstable.sqlc
      unstable.cfssl
      unstable.protoc-gen-go
      unstable.protoc-gen-go-grpc
      unstable.glow
      unstable.soft-serve
      unstable.golangci-lint
      unstable.lazydocker
      minimock
      go-task
      enumer
      scc
      goose
    ];

    home.sessionPath = ["$HOME/go/bin"];

    programs.zsh.oh-my-zsh.plugins = ["golang"];
  };
}