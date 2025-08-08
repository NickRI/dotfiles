{ pkgs, lib, ... }:

let
  geo = import ../tools/geo {
    inherit pkgs;
  };

  listen-address = "127.0.0.1:1223";
in
{
  systemd.services.wifi-geo-location = {
    description = "Custom GeoClue2 Location Provider";
    requires = [ "geoclue.service" ];
    serviceConfig = {
      ExecStart = "${geo}/bin/geo --listen ${listen-address}";
      Restart = "on-failure";
    };
  };

  systemd.services.geoclue = {
    after = [ "wifi-geo-location.service" ];
    wants = [ "wifi-geo-location.service" ];
  };

  time.timeZone = lib.mkForce null; # Force to do it automatically

  systemd.services.timezone-update = {
    description = "timezone update service";
    wantedBy = [ "multi-user.target" ];
    wants = [ "wifi-geo-location.service" ];
    after = [ "wifi-geo-location.service" ];
    script = ''
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

  systemd.timers.timezone-update = {
    enable = true;
    timerConfig = {
      OnStartupSec = "30s";
      OnCalendar = "hourly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  services.geoclue2 = {
    enable = true;
    geoProviderUrl = "http://${listen-address}";
  };
}
