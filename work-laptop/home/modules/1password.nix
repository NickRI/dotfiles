{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    home.file = {
      ".config/1Password/ssh/agent.toml".text = ''
        [[ssh-keys]]
        item =  "Github"
        vault = "work"

        [[ssh-keys]]
        item =  "Soho-key"
        vault = "soho"
      '';
    };

    programs.chromium = lib.mkIf (config.programs.chromium.enable) {
      extensions = [
        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
      ];
    };

    programs.ssh = lib.mkIf (config.programs.ssh.enable) {
      extraConfig = ''
        IdentityAgent = ~/.1password/agent.sock
      '';
    };

    programs.zsh = lib.mkIf (config.programs.zsh.enable) {
      oh-my-zsh.plugins = [ "1password" ];
    };

    autoStart = [ pkgs.unstable._1password-gui ];
  };
}
