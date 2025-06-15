{
  config,
  pkgs,
  lib,
  ...
}:
let
  upkgs = pkgs.unstable;
in
{
  config = {
    home.packages = with upkgs; [
      rustup
    ];

    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
