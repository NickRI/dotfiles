{ pkgs, ... }:

pkgs.buildGoModule {
  pname = "wormhole-drop";
  version = "0.1.0";

  src = ./.;

  vendorHash = null;

  meta = with pkgs.lib; {
    description = "Go wormhole drop application";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
