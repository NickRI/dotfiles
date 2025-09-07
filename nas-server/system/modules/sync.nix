{
  config,
  pkgs,
  lib,
  ...
}:
let
  syncthing-listen-port = 8384;

  # TODO: Delete it with time
  updateAuthConfig = pkgs.writers.writeBash "merge-syncthing-auth" (
    ''
      set -efu

      # be careful not to leak secrets in the filesystem or in process listings
      umask 0077

      curl() {
          # get the api key by parsing the config.xml
          while
              ! ${pkgs.libxml2}/bin/xmllint \
                  --xpath 'string(configuration/gui/apikey)' \
                  ${config.services.syncthing.configDir}/config.xml \
                  >"$RUNTIME_DIRECTORY/api_key"
          do sleep 1; done
          (printf "X-API-Key: "; cat "$RUNTIME_DIRECTORY/api_key") >"$RUNTIME_DIRECTORY/headers"
          ${pkgs.curl}/bin/curl -sSLk -H "@$RUNTIME_DIRECTORY/headers" \
              --retry 1000 --retry-delay 1 --retry-all-errors \
              "$@"
      }
    ''
    + lib.optionalString (config.services.syncthing.enable) ''
      curl -X PATCH -d @${
        config.sops.templates."authFile".path
      } ${config.services.syncthing.guiAddress}/rest/config/gui
    ''
  );
in
{
  hosts.entries = {
    syncthing = lib.mkIf (config.services.syncthing.enable) {
      domain = "syncthing.nas.firefly.red";
      local-port = syncthing-listen-port;
    };
  };

  homepage.services = {
    Downloads = {
      Syncthing = lib.mkIf (config.services.syncthing.enable) rec {
        description = "Open Source Continuous File Synchronization";
        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/syncthing.svg";
        href = "https://syncthing.nas.firefly.red/";
        siteMonitor = href;
      };
    };
  };

  sops = lib.mkIf (config.services.syncthing.enable) {
    secrets = {
      "syncthing/key".owner = "syncthing";
      "syncthing/cert".owner = "syncthing";
      "syncthing/user" = { };
      "syncthing/password" = { };
    };

    templates."authFile" = {
      mode = "0644";
      owner = "syncthing";
      content = ''
        {
          "user": "${config.sops.placeholder."syncthing/user"}",
          "password": "${config.sops.placeholder."syncthing/password"}"
        }'';
    };
  };

  systemd.services.syncthing-auth = lib.mkIf (config.services.syncthing.enable) {
    description = "Syncthing auth configuration updater";
    requisite = [ "syncthing-init.service" ];
    after = [ "syncthing-init.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = config.services.syncthing.user;
      RemainAfterExit = true;
      RuntimeDirectory = "syncthing-auth";
      Type = "oneshot";
      ExecStart = updateAuthConfig;
    };
  };

  services.syncthing = {
    guiAddress = "127.0.0.1:${toString syncthing-listen-port}";
    enable = true;
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    settings = {
      gui = {
        theme = "dark";
        insecureSkipHostcheck = true;
      };
      devices = {
        work-laptop = {
          id = "JRUHEE6-DNV7VIY-H3A35Y5-VAZHJ7K-XNIXUC6-SEDS3BJ-EEBPRPZ-Z5UCCAO";
          name = "work-laptop";
        };
      };

      folders = {
        nikolai-downloads = {
          path = "/storage/syncthing/nikolai/downloads";
          devices = [ "work-laptop" ];
          versioning = {
            type = "simple";
            params = {
              keep = "10";
              cleanoutDays = "180";
            };
          };
        };
        nikolai-music = {
          path = "/storage/syncthing/nikolai/music";
          devices = [ "work-laptop" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-images = {
          path = "/storage/syncthing/nikolai/images";
          devices = [ "work-laptop" ];
          versioning = {
            type = "simple";
            params = {
              keep = "10";
              cleanoutDays = "180";
            };
          };
        };
        nikolai-videos = {
          path = "/storage/syncthing/nikolai/videos";
          devices = [ "work-laptop" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-documents = {
          path = "/storage/syncthing/nikolai/documents";
          devices = [ "work-laptop" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-desktop = {
          path = "/storage/syncthing/nikolai/desktop";
          devices = [ "work-laptop" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-dropbox = {
          path = "/storage/syncthing/nikolai/dropbox";
          devices = [ "work-laptop" ];
          pullerMaxPendingKiB = 65536;
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
        nikolai-go-code = {
          path = "/storage/syncthing/nikolai/code/go";
          devices = [ "work-laptop" ];
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
