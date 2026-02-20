{ config, lib, ... }:

{
  config = {
    networking.hostName = "tv-box"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    sops = {
      secrets = {
        "networking/wifi/home/login" = { };
        "networking/wifi/home/password" = { };
      };

      templates."wireless.env" = {
        content = ''
          HOME_WIFI_SSID=${config.sops.placeholder."networking/wifi/home/login"}
          HOME_WIFI_PASSWORD=${config.sops.placeholder."networking/wifi/home/password"}
        '';
      };
    };

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ config.sops.templates."wireless.env".path ];
        profiles = {
          home-wifi = {
            connection.id = "home-wifi";
            connection.type = "wifi";
            wifi.ssid = "$HOME_WIFI_SSID";
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$HOME_WIFI_PASSWORD";
            };
          };
        };
      };
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    networking.firewall.allowedTCPPorts = [
      80
      443
      8080
    ];

    #    networking.nameservers = [ "127.0.0.1" ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp170s0.useDHCP = lib.mkDefault true;
  };
}
