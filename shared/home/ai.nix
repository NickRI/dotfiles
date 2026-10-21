{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = lib.getExe pkgs.unstable.mcp-nixos;
        enabled = true;
      };

      github = {
        command = lib.getExe pkgs.unstable.github-mcp-server;
        env.GITHUB_PERSONAL_ACCESS_TOKEN = lib.mkIf (config.sops.secrets ? "mcp/github-token") {
          file = config.sops.secrets."mcp/github-token".path;
        };
        enabled = true;
      };

      gitea = {
        command = lib.getExe pkgs.unstable.gitea-mcp-server;
        args = [
          "-t"
          "stdio"
          "-H"
          "https://gitea.nas.firefly.red"
        ];
        env.GITEA_ACCESS_TOKEN = lib.mkIf (config.sops.secrets ? "mcp/gitea-token") {
          file = config.sops.secrets."mcp/gitea-token".path;
        };
        enabled = true;
      };
    };
  };
}
