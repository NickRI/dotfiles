{config, pkgs, lib, ...}:

{
  config = {
    home.packages = [
      pkgs.unstable.rustup
    ];

    home.sessionPath = ["$HOME/.cargo/bin"];

    programs.zsh = lib.mkIf (config.programs.zsh.enable) {
      oh-my-zsh.plugins = [ "rust" ];
    };
  };
}