{ config, lib, ... }:

{
  programs.kodi = lib.mkIf (config.programs.kodi.enable) {
    settings = {
      weather.addon = "weather.gismeteo";
      weather.currentlocation = "1";
    };
    addonSettings = {
      "weather.gismeteo"."CurrentLocation" = "true";
      "weather.gismeteo"."Location1" = "Saint Petersburg";
      "weather.gismeteo"."Location1ID" = "4079";
      "weather.gismeteo"."Language" = "0";
      "weather.gismeteo"."Weekend" = "0";
      "weather.gismeteo"."TimeZone" = "0";
      "weather.gismeteo"."PresUnit" = "0";
      "weather.gismeteo"."PrecipUnit" = "0";
      "weather.gismeteo"."UseProviderIcons" = "false";
    };
  };
}
