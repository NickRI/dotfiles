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
  version = "11.0.95";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-M0XjTmsAXtoPdIWFvS5WFKkOKjqySiKfo08D1VQr780=";
  };

  meta = {
    homepage = "https://kodi.tv/";
    description = "Russian translation for KODI";
    license = lib.licenses.psfl;
    teams = [ lib.teams.kodi ];
  };
}
