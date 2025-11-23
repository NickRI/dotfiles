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
    requires = [ "geoclue.service" ];
    serviceConfig = {
      ExecStart = "${geo}/bin/geo --listen ${listen-address}";
      CacheDirectory = "wifi-geo";
      Restart = "on-failure";
    };
  };

  systemd.services.geoclue = {
    after = [ "wifi-geo-location.service" ];
    wants = [ "wifi-geo-location.service" ];
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
    wants = [ "wifi-geo-location.service" ];
    after = [ "wifi-geo-location.service" ];
    script = ''
      echo "Waiting for geo server..."
      until ${pkgs.curl}/bin/curl -sS http://${listen-address}/time-zone >/dev/null 2>&1; do
        sleep 2
      done
            
      timezone="$(${pkgs.curl}/bin/curl -sS http://${listen-address}/time-zone)"
      if [[ -n "$timezone" ]]; then
        echo "Setting timezone to '$timezone'"
        timedatectl set-timezone "$timezone"
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Tricky way to capture wifi up
  environment.etc."NetworkManager/dispatcher.d/10-wifi-up".source =
    pkgs.writeShellScript "wifi-up-hook" ''
      if [ "$2" = "up" ]; then
        systemctl start geo-timezone-update.service
      fi
    '';
}
