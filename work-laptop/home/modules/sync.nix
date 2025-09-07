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
  sops = lib.mkIf (config.services.syncthing.enable) {
    secrets."syncthing/key" = {
      mode = "0644";
    };
    secrets."syncthing/cert" = {
      mode = "0644";
    };
  };

  home.packages =
    with upkgs;
    lib.mkIf (config.services.syncthing.enable) [
      syncthingtray
    ];

  autoStart =
    with upkgs;
    lib.mkIf (config.services.syncthing.enable) [
      syncthingtray
    ];

  # Overridden to hide
  xdg.desktopEntries.syncthing-ui = {
    name = "Syncthing UI";
    noDisplay = true;
    type = "Application";
  };

  services.syncthing = {
    enable = true;
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;

    settings = {
      devices = {
        nas = {
          id = "AI5QU3E-3LRXFC3-523PGMF-SX6P6ZU-56HDJFJ-BQFZDI2-DMQAW4P-QFNDQAT";
          name = "nas-server";
        };
      };

      folders = {
        nikolai-downloads = {
          path = "${config.home.homeDirectory}/Загрузки";
          devices = [ "nas" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-music = {
          path = "${config.home.homeDirectory}/Музыка";
          devices = [ "nas" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-images = {
          path = "${config.home.homeDirectory}/Изображения";
          devices = [ "nas" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-videos = {
          path = "${config.home.homeDirectory}/Видео";
          devices = [ "nas" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-documents = {
          path = "${config.home.homeDirectory}/Документы";
          devices = [ "nas" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-desktop = {
          path = "${config.home.homeDirectory}/Рабочий стол";
          devices = [ "nas" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-dropbox = {
          path = "${config.home.homeDirectory}/Dropbox";
          devices = [ "nas" ];
          pullerMaxPendingKiB = 65536;
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-go-code = {
          path = "${config.home.homeDirectory}/go/src";
          devices = [ "nas" ];
          pullerMaxPendingKiB = 65536;
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
      };
    };
  };
}
