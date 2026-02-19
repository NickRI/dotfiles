{
  lib,
  rel,
  future,
  fetchzip,
  buildKodiAddon,
  ...
}:
let
  simpleplugin3 = buildKodiAddon rec {
    pname = "simpleplugin3";
    namespace = "script.module.simpleplugin3";
    version = "3.0.6+matrix.1";

    src = fetchzip {
      url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
      sha256 = "sha256-kNIhxea3v7a+EfVhdzf460ZAtgv8m6XfhAMiTDfbRX4=";
    };

    propagatedBuildInputs = [
      future
    ];

    meta = {
      homepage = "https://github.com/vlmaksime/script.module.simpleplugin";
      description = "A micro-framework for Kodi mediacenter content plugins";
      license = lib.licenses.psfl;
      teams = [ lib.teams.kodi ];
    };
  };
in
buildKodiAddon rec {
  pname = "gismeteo";
  namespace = "weather.gismeteo";
  version = "0.6.4+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-I9/vDbmkAEjJlAtjT8iBKslMZPOGbblnHuleL/OGfIg=";
  };

  propagatedBuildInputs = [
    simpleplugin3
  ];

  meta = {
    homepage = "https://github.com/vlmaksime/weather.gismeteo";
    description = "Gismeteo Weather Forecast for KODI";
    license = lib.licenses.psfl;
    teams = [ lib.teams.kodi ];
  };
}
