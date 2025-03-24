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
      jetbrains.goland
      jetbrains.datagrip

      cfssl
      scc
      glow
      soft-serve
      lazydocker
      goose
      go-task
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
