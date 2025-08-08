{ pkgs, lib, ... }:

let
  geo = import ../tools/geo {
    inherit pkgs;
  };

  listen-address = "127.0.0.1:443";
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
    geoProviderUrl = "https://www.googleapis.com/geolocation/v1/geolocate";
  };

  # Chromium and others hack
  networking.extraHosts = ''
    127.0.0.1 googleapis.com
    127.0.0.1 www.googleapis.com
  '';

  security.pki.certificateFiles = [
    ../tools/geo/googleapis-hack/www.googleapis.com.crt
  ];

  # Timezone setter
  time.timeZone = lib.mkForce null; # Force to do it automatically

  systemd.services.geo-timezone-update = {
    description = "Timezone update service";
    wants = [ "wifi-geo-location.service" ];
    after = [ "wifi-geo-location.service" ];
    script = ''
      timezone="$(${pkgs.curl}/bin/curl -sS https://www.googleapis.com/time-zone)"
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
