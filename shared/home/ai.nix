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
        env = lib.optionalAttrs (config.sops.secrets ? "mcp/github-token") {
          GITHUB_PERSONAL_ACCESS_TOKEN.file = config.sops.secrets."mcp/github-token".path;
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
        env = lib.optionalAttrs (config.sops.secrets ? "mcp/gitea-token") {
          GITEA_ACCESS_TOKEN.file = config.sops.secrets."mcp/gitea-token".path;
        };
        enabled = true;
      };
    };
  };
}
