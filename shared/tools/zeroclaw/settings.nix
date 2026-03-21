{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.zeroclaw;
  tomlFormat = pkgs.formats.toml { };

  settingsType = lib.types.submoduleWith {
    modules = import ./settings;
  };

  # TOML не поддерживает null; пустые вложенные attrset убираем (лишние секции).
  sanitizeForToml =
    v:
    if v == null then
      null
    else if lib.isAttrs v then
      let
        withoutNulls = lib.filterAttrs (_: x: x != null) v;
        pruned = lib.mapAttrs (_: sanitizeForToml) withoutNulls;
        pruned2 = lib.filterAttrs (_: val: !(lib.isAttrs val && val == { })) pruned;
      in
      if pruned2 == { } then { } else pruned2
    else if lib.isList v then
      map sanitizeForToml (lib.filter (x: x != null) v)
    else
      v;

  configFile = tomlFormat.generate "zeroclaw-config" (sanitizeForToml cfg.settings);
in
{
  options.services.zeroclaw.settings = lib.mkOption {
    description = "Zeroclaw main config.";
    type = settingsType;
  };

  config = lib.mkIf cfg.enable {
    services.zeroclaw.settings.agent.tool_call_dedup_exempt = [ ];
    services.zeroclaw.settings.agent.tool_filter_groups = [ ];
    services.zeroclaw.settings.autonomy.allowed_commands = [
      "git"
      "npm"
      "cargo"
      "ls"
      "cat"
      "grep"
      "find"
      "echo"
      "pwd"
      "wc"
      "head"
      "tail"
      "date"
    ];
    services.zeroclaw.settings.autonomy.allowed_roots = [ ];
    services.zeroclaw.settings.autonomy.always_ask = [ ];
    services.zeroclaw.settings.autonomy.auto_approve = [
      "file_read"
      "memory_recall"
    ];
    services.zeroclaw.settings.autonomy.forbidden_paths = [
      "/etc"
      "/root"
      "/home"
      "/usr"
      "/bin"
      "/sbin"
      "/lib"
      "/opt"
      "/boot"
      "/dev"
      "/proc"
      "/sys"
      "/var"
      "/tmp"
      "~/.ssh"
      "~/.gnupg"
      "~/.aws"
      "~/.config"
    ];
    services.zeroclaw.settings.autonomy.non_cli_excluded_tools = [ ];
    services.zeroclaw.settings.autonomy.shell_env_passthrough = [ ];
    services.zeroclaw.settings.backup.include_dirs = [
      "config"
      "memory"
      "audit"
      "knowledge"
    ];
    services.zeroclaw.settings.browser.allowed_domains = [ ];
    services.zeroclaw.settings.browser.computer_use.window_allowlist = [ ];
    services.zeroclaw.settings.browser_delegate.allowed_domains = [ ];
    services.zeroclaw.settings.browser_delegate.blocked_domains = [ ];
    services.zeroclaw.settings.cloud_ops.iac_tools = [ "terraform" ];
    services.zeroclaw.settings.cloud_ops.supported_clouds = [
      "aws"
      "azure"
      "gcp"
    ];
    services.zeroclaw.settings.cloud_ops.well_architected_frameworks = [ "aws-waf" ];
    services.zeroclaw.settings.data_retention.categories = [ ];
    services.zeroclaw.settings.embedding_routes = [ ];
    services.zeroclaw.settings.gateway.paired_tokens = [ ];
    services.zeroclaw.settings.google_workspace.allowed_services = [ ];
    services.zeroclaw.settings.hooks.builtin.webhook_audit.tool_patterns = [ ];
    services.zeroclaw.settings.http_request.allowed_domains = [ ];
    services.zeroclaw.settings.linkedin.content.github_repos = [ ];
    services.zeroclaw.settings.linkedin.content.github_users = [ ];
    services.zeroclaw.settings.linkedin.content.rss_feeds = [ ];
    services.zeroclaw.settings.linkedin.content.topics = [ ];
    services.zeroclaw.settings.linkedin.image.providers = [
      "stability"
      "imagen"
      "dalle"
      "flux"
    ];
    services.zeroclaw.settings.mcp.servers = [ ];
    services.zeroclaw.settings.microsoft365.scopes = [ "https://graph.microsoft.com/.default" ];
    services.zeroclaw.settings.model_routes = [ ];
    services.zeroclaw.settings.node_transport.allowed_peers = [ ];
    services.zeroclaw.settings.peripherals.boards = [ ];
    services.zeroclaw.settings.proxy.no_proxy = [ ];
    services.zeroclaw.settings.proxy.services = [ ];
    services.zeroclaw.settings.query_classification.rules = [ ];
    services.zeroclaw.settings.reliability.api_keys = [ ];
    services.zeroclaw.settings.reliability.fallback_providers = [ ];
    services.zeroclaw.settings.runtime.docker.allowed_workspace_roots = [ ];
    services.zeroclaw.settings.security.nevis.role_mapping = [ ];
    services.zeroclaw.settings.security.otp.gated_actions = [
      "shell"
      "file_write"
      "browser_open"
      "browser"
      "memory_forget"
    ];
    services.zeroclaw.settings.security.otp.gated_domain_categories = [ ];
    services.zeroclaw.settings.security.otp.gated_domains = [ ];
    services.zeroclaw.settings.security.sandbox.firejail_args = [ ];
    services.zeroclaw.settings.web_fetch.allowed_domains = [ "*" ];
    services.zeroclaw.settings.web_fetch.blocked_domains = [ ];
    systemd.services.zeroclaw.restartTriggers = [ configFile ];

    sops.templates."zeroclaw-config" = {
      owner = cfg.user;
      content = builtins.readFile configFile;
    };
  };
}
