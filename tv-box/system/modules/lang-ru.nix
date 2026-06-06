{
  lib,
  rel,
  fetchzip,
  buildKodiAddon,
  ...
}:

buildKodiAddon rec {
  pname = "Russian Language";
  namespace = "resource.language.ru_ru";
  version = "11.0.101";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-KgohkdcOTMYax9rORt46xj70suEwTeIDW3u8mmc4RWA=";
  };

  meta = {
    homepage = "https://kodi.tv/";
    description = "Russian translation for KODI";
    license = lib.licenses.psfl;
    teams = [ lib.teams.kodi ];
  };
}
