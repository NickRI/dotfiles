{ config, unstable, ... }:

{
  config = {
    home.packages = [
      unstable.go
    ];

    home.sessionPath = ["$HOME/go/bin"];

    programs.zsh.oh-my-zsh.plugins = ["golang"];
  };
}