{ pkgs, geo-server-url, ... }:

pkgs.stdenv.mkDerivation {
  name = "geo-extension";
  src = ./.;

  buildPhase = ''
    substituteInPlace ./inject.js --replace-fail "__SERVER_URL__" "${geo-server-url}"
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out/src
    ${pkgs.go-crx3}/bin/crx3 pack $out/src -o $out/geo-extension.crx
  '';
}
