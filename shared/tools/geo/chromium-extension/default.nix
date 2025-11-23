{ pkgs, geo-server-url, ... }:
let
  version = "1.1";
  buildDeriv = pkgs.stdenv.mkDerivation {
    name = "geo-extension";
    src = ./.;

    buildPhase = ''
      substituteInPlace ./background.js --replace-fail "__SERVER_URL__" "${geo-server-url}"
      substituteInPlace ./manifest.json --replace-fail "__SERVER_URL__" "${geo-server-url}"
      substituteInPlace ./manifest.json --replace-fail "__VERSION__" "${version}"
    '';

    installPhase = ''
      mkdir -p $out
      cp -r . $out/src
      ${pkgs.go-crx3}/bin/crx3 pack $out/src -o $out/geo-extension.crx
      ${pkgs.go-crx3}/bin/crx3 id $out/geo-extension.crx > $out/extension-id
    '';

  };

  extension = buildDeriv // {
    extensionId = pkgs.lib.strings.trim (builtins.readFile "${buildDeriv}/extension-id");
    version = version;
  };
in
extension
