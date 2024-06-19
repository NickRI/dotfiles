{ config, unstable, ... }:

{
  config = {
    home.packages = [
      unstable.rustup
    ];

    home.sessionPath = ["$HOME/.cargo/bin"];

    programs.zsh.oh-my-zsh.plugins = ["rust"];
  };
}