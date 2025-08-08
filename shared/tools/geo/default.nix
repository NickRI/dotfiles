{ pkgs, ... }:

pkgs.buildGoModule {
  pname = "geo";
  version = "0.1.0";

  src = ./.;

  vendorHash = null;

  meta = with pkgs.lib; {
    description = "Go geolocation application";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
