{ config, unstable, ... }:

{
  config = {
    home.packages = [
      unstable.go
    ];

    home.sessionVariables = { # Need to reboot
      PATH = "$HOME/go/bin:$PATH";
    };
  };
}