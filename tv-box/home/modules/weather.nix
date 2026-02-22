{ config, lib, ... }:

{
  programs.kodi = lib.mkIf (config.programs.kodi.enable) {
    addonSettings = {
      "weather.gismeteo"."CurrentLocation" = "false";
      "weather.gismeteo"."Location1" = "Callosa de Segura";
      "weather.gismeteo"."Location1ID" = "49754";
      "weather.gismeteo"."Location2" = "Saint Petersburg";
      "weather.gismeteo"."Location2ID" = "4079";
      "weather.gismeteo"."Language" = "0";
      "weather.gismeteo"."Weekend" = "0";
      "weather.gismeteo"."TimeZone" = "0";
      "weather.gismeteo"."PresUnit" = "0";
      "weather.gismeteo"."PrecipUnit" = "0";
      "weather.gismeteo"."UseProviderIcons" = "false";
    };
  };
}
