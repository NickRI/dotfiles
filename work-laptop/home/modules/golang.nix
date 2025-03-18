{
  config,
  pkgs,
  lib,
  ...
}:
let

  upkgs = pkgs.unstable;

  inherit (pkgs) fetchFromGitHub;

  sqlc = upkgs.sqlc.overrideAttrs (oldAttrs: rec {
    version = "1.27.0";
    vendorHash = "sha256-ndOw3uShF5TngpxYNumoK3H3R9v4crfi5V3ZCoSqW90=";

    src = fetchFromGitHub {
      owner = oldAttrs.src.owner;
      repo = oldAttrs.src.repo;
      rev = "v${version}";
      sha256 = "sha256-wxQ+YPsDX0Z6B8whlQ/IaT2dRqapPL8kOuFEc6As1rU=";
    };
  });

  minimock = upkgs.go-minimock.overrideAttrs (oldAttrs: rec {
    version = "3.1.3";
    vendorHash = "sha256-fiSU2NB9rWIPQLdnui5CB5VcadTVUg2JaO3ma7DAYqo=";

    src = fetchFromGitHub {
      owner = oldAttrs.src.owner;
      repo = oldAttrs.src.repo;
      rev = "v${version}";
      sha256 = "sha256-6n5FOHTfsLYqnhlDO3etMnrypeOElmwdvoFQb3aSBts=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];
  });

  enumer = upkgs.enumer.overrideAttrs (oldAttrs: rec {
    version = "1.5.10";
    vendorHash = "sha256-CJCay24FlzDmLjfZ1VBxih0f+bgBNu+Xn57QgWT13TA=";

    doCheck = false;

    src = fetchFromGitHub {
      owner = oldAttrs.src.owner;
      repo = oldAttrs.src.repo;
      rev = "refs/tags/v${version}";
      hash = "sha256-7tU1etCrgG05HU1N9c1o2S9VNXRONFBCoM317pIddcw=";
    };
  });

  golangci-lint = upkgs.golangci-lint.overrideAttrs (oldAttrs: rec {
    version = "1.60.3";
    vendorHash = "sha256-ixeswsfx36D0Tg103swbBD8UXXLNYbxSMYDE+JOm+uw=";

    src = fetchFromGitHub {
      owner = oldAttrs.src.owner;
      repo = oldAttrs.src.repo;
      rev = "refs/tags/v${version}";
      hash = "sha256-0ScdJ5td2N8WF1dwHQ3dBSjyr1kqgrzCfBzbRg9cRrw=";
    };
  });
in
{
  config = {
    programs.go = {
      enable = true;
      package = upkgs.go;
      goPrivate = [
        "github.com/wert-io"
      ];
    };

    home.sessionPath = [ "$HOME/go/bin" ];

    home.sessionVariables = {
      GOPROXY = "https://athens.nas.firefly.red";
    };

    home.packages = with upkgs; [
      jetbrains.goland
      jetbrains.datagrip

      cfssl
      protoc-gen-go
      protoc-gen-go-grpc
      scc
      glow
      soft-serve
      lazydocker
      delve
      goose
      go-task
      golangci-lint
      minimock
      enumer
      sqlc
      gollama
    ];

    programs.chromium = lib.mkIf (config.programs.chromium.enable) {
      extensions = [
        { id = "adhapdickilojlhiicaffdhbgaedfodo"; } # Go playground
      ];
    };

    programs.zsh = lib.mkIf (config.programs.zsh.enable) {
      oh-my-zsh.plugins = [ "golang" ];
    };
  };
}
