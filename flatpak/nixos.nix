{ config, pkgs, ... }:

{
  imports = [ ./default.nix ];

  config = {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}