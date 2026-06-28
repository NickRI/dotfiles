{
  pkgs,
  config,
  lib,
  ...
}:

{
  sops.secrets."tailscale-token" = { };

  services.tailscale = {
    enable = true;
    openFirewall = true;

    useRoutingFeatures = "client";

    authKeyFile = config.sops.secrets."tailscale-token".path;

    extraUpFlags = [
      "--accept-routes=true"
    ];

    extraSetFlags = [
      "--operator=${config.users.users.nikolai.name}"
    ];
  };

  home-manager.users.nikolai = {
    home.packages = with pkgs.gnomeExtensions; [ tailscale-qs-2 ];

    dconf.settings = with lib.hm.gvariant; {
      "org/gnome/shell" = {
        enabled-extensions = [ "tailscale-gnome-qs@tailscale-qs.github.io" ];
      };
    };
  };
}
