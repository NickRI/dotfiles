{
  config,
  lib,
  pkgs,
  ...
}:

{
  # The memory server does not create the parent directory of its file, so the
  # directory has to exist before the first write.
  home.file.".local/share/mcp-memory/.keep".text = "";

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

      git = {
        command = lib.getExe pkgs.unstable.mcp-server-git;
        enabled = true;
      };

      memory = {
        command = lib.getExe pkgs.unstable.mcp-server-memory;
        env.MEMORY_FILE_PATH = "${config.xdg.dataHome}/mcp-memory/memory.jsonl";
        enabled = true;
      };

      grafana = {
        command = lib.getExe pkgs.unstable.mcp-grafana;
        # Keep the tool surface small: write tools are not needed for reading
        # dashboards, metrics and logs.
        args = [ "--disable-write" ];
        env = {
          GRAFANA_URL = "https://grafana.nas.firefly.red";
        }
        // lib.optionalAttrs (config.sops.secrets ? "mcp/grafana-token") {
          GRAFANA_SERVICE_ACCOUNT_TOKEN.file = config.sops.secrets."mcp/grafana-token".path;
        };
        enabled = true;
      };
    };
  };
}
