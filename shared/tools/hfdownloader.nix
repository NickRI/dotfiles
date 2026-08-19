{
  config,
  pkgs,
  lib,
  ...
}:

let
  version = "3.2.0";

  hfdownloader-pkg = pkgs.buildGoModule {
    pname = "hfdownloader";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "bodaay";
      repo = "HuggingFaceModelDownloader";
      rev = "v${version}";
      hash = "sha256-XSyAOfh4BrVxcaqB7+1E9gRkTBM6CHNsG2V2BtITv4g=";
    };

    vendorHash = "sha256-DUALCwhuwQZ94uOVjw5wyY8z3fYr9WyDwVc89U34ytM=";

    subPackages = [ "cmd/hfdownloader" ];

    env.CGO_ENABLED = "0";
    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    meta = with lib; {
      description = "Fast, resumable downloader for Hugging Face models and datasets";
      homepage = "https://github.com/bodaay/HuggingFaceModelDownloader";
      license = licenses.asl20;
      mainProgram = "hfdownloader";
    };
  };

  cfg = config.services.hfdownloader;
in
{
  options.services.hfdownloader = {
    enable = lib.mkEnableOption "HuggingFace Downloader web server";

    package = lib.mkOption {
      type = lib.types.package;
      default = hfdownloader-pkg;
      description = "hfdownloader package.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "hfdownloader";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "hfdownloader";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8090;
    };

    cacheDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/hfdownloader";
      description = "HuggingFace cache directory (--cache-dir).";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File containing the HuggingFace token (raw value).";
    };

    authUserFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File with basic-auth username.";
    };

    authPassFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File with basic-auth password.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == "hfdownloader") {
      hfdownloader = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.cacheDir;
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "hfdownloader") {
      hfdownloader = { };
    };

    systemd.tmpfiles.rules = [
      # Ensure cacheDir exists before systemd tries to CHDIR into it.
      "d ${cfg.cacheDir} 0755 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.hfdownloader = {
      description = "HuggingFace Downloader web server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";
      };

      script = ''
        ${lib.optionalString (cfg.tokenFile != null) ''
          export HF_TOKEN=$(cat ${cfg.tokenFile})
        ''}
        ${lib.optionalString (cfg.authUserFile != null) ''
          auth_user=$(cat ${cfg.authUserFile})
        ''}
        ${lib.optionalString (cfg.authPassFile != null) ''
          auth_pass=$(cat ${cfg.authPassFile})
        ''}
        exec ${cfg.package}/bin/hfdownloader serve \
          --addr ${cfg.listenAddress} \
          --port ${toString cfg.port} \
          --cache-dir ${cfg.cacheDir} \
          ${lib.optionalString (cfg.authUserFile != null) ''--auth-user "$auth_user"''} \
          ${lib.optionalString (cfg.authPassFile != null) ''--auth-pass "$auth_pass"''}
      '';

      restartTriggers = [
        cfg.listenAddress
        (toString cfg.port)
        cfg.cacheDir
      ];
    };
  };
}
