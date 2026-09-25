{ pkgs, ... }:

{
  environment.systemPackages = with pkgs.unstable; [
    bitwarden-desktop
    bitwarden-cli
  ];

  home-manager.users.nikolai =
    {
      config,
      lib,
      ...
    }:
    {
      home.shellAliases = {
        "bw-unlock" = ''export BW_SESSION="$(bw unlock --raw)"'';
        "sops-master" =
          "SOPS_AGE_KEY=$(bw get item nix-secrets | jq -r '.sshKey.privateKey' | nix run nixpkgs#ssh-to-age -- -private-key) sops";
      };

      programs.ssh = lib.mkIf config.programs.ssh.enable {
        enableDefaultConfig = false;

        settings = {
          "*" = {
            identityAgent = "~/.bitwarden-ssh-agent.sock";
          };
        };
      };

      home.sessionVariables = {
        SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
      };

      programs.chromium = lib.mkIf (config.programs.chromium.enable) {
        extensions = [
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        ];
      };
    };
}
