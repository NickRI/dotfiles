{config, pkgs, lib, ...}:

{
  config = {
    home.packages = [
      pkgs.rustup
    ];

    home.sessionPath = ["$HOME/.cargo/bin"];

    programs.zsh = lib.mkIf (config.programs.zsh.enable) {
      oh-my-zsh.plugins = [ "rust" ];
    };
  };
}