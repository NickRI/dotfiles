{
  config,
  pkgs,
  lib,
  ...
}:
let
  upkgs = pkgs.unstable;
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
      pkgs.jetbrains.goland
      pkgs.jetbrains.datagrip

      cfssl
      scc
      glow
      soft-serve
      lazydocker
      lazygit
      goose
      go-task
      gollama
    ];

    programs.chromium = lib.mkIf (config.programs.chromium.enable) {
      extensions = [
        { id = "adhapdickilojlhiicaffdhbgaedfodo"; } # Go playground
      ];
    };
  };
}
