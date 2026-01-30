{ pkgs, lib, ... }:

let
  geo = import ../tools/geo {
    inherit pkgs;
  };

  listen-address = "127.0.0.1:1223";

  geo-chrome-extension = import ../tools/geo/chromium-extension {
    inherit pkgs;
    geo-server-url = "http://${listen-address}/geolocate";
  };

in
{
  systemd.services.wifi-geo-location = {
    description = "Custom GeoClue2 Location Provider";
    serviceConfig = {
      ExecStart = "${geo}/bin/geo --listen ${listen-address}";
      CacheDirectory = "wifi-geo";
      Restart = "on-failure";
      Type = "simple";
    };
  };

  systemd.services.geoclue = {
    after = lib.mkAfter [ "wifi-geo-location.service" ];
    wants = lib.mkAfter [ "wifi-geo-location.service" ];
  };

  services.geoclue2 = {
    enable = true;
    geoProviderUrl = "http://${listen-address}/geolocate";
  };

  # Chromium and others hack
  home-manager.users.nikolai =
    {
      ...
    }:
    {
      programs.chromium = {
        extensions = [
          {
            id = "${geo-chrome-extension.extensionId}";
            crxPath = "${geo-chrome-extension}/geo-extension.crx";
            version = "${geo-chrome-extension.version}";
          }
        ];
      };

    };

  # Timezone setter
  time.timeZone = lib.mkForce null; # Force to do it automatically

  systemd.services.geo-timezone-update = {
    description = "Timezone update service";
    requires = [ "wifi-geo-location.service" ];
    after = [ "wifi-geo-location.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = ''
        echo "Waiting for geo service..."
        until ${pkgs.curl}/bin/curl -fsS http://${listen-address}/time-zone >/dev/null; do
          sleep 2
        done
      '';
    };

    script = ''
      timezone="$(${pkgs.curl}/bin/curl -fsS http://${listen-address}/time-zone)"
      timedatectl set-timezone "$timezone"
    '';
  };

  # Tricky way to capture wifi up
  environment.etc."NetworkManager/dispatcher.d/10-wifi-up".source =
    pkgs.writeShellScript "wifi-up-hook" ''
      if [ "$2" = "up" ]; then
        systemctl try-restart geo-timezone-update.service
      fi
    '';
}
