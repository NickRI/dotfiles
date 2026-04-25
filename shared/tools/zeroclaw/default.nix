{
  config,
  lib,
  pkgs,
  ...
}:

let
  version = "v0.7.3";

  zeroclawSrc = pkgs.fetchFromGitHub {
    owner = "zeroclaw-labs";
    repo = "zeroclaw";
    rev = version;
    hash = "sha256-Lr30nJ2IRAZzxS8Dc43c5mj3ab2suVbZxLTLx0mBRF0=";
  };

  zeroclawWeb = pkgs.buildNpmPackage {
    pname = "zeroclaw-web";
    inherit version;
    src = zeroclawSrc;
    sourceRoot = "${zeroclawSrc.name}/web";

    npmDepsHash = "sha256-0AThpojpIjfjLfhfVlBWsJw4e7ksyi0nX4T60PHB2gc=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/assets
      cp -r dist/assets/* $out/assets/
      cp dist/index.html $out/
      cp dist/logo.png $out/zeroclaw-trans.png || true
      runHook postInstall
    '';
  };

  zeroclawPkg = pkgs.rustPlatform.buildRustPackage rec {
    pname = "zeroclaw";
    inherit version;

    src = zeroclawSrc;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      allowBuiltinFetchGit = true;
    };

    doCheck = false;

    meta = with lib; {
      description = "Fast, small, autonomous AI assistant infrastructure (ZeroClaw)";
      homepage = "https://github.com/zeroclaw-labs/zeroclaw";
      license = with licenses; [
        mit
        asl20
      ];
      maintainers = [ ];
    };
  };

  cfg = config.services.zeroclaw;
in
{

  imports = [
    ./settings.nix
    ./workspace.nix
    ./agent-browser.nix
  ];

  options.services.zeroclaw = {
    enable = lib.mkEnableOption "ZeroClaw AI assistant (daemon or gateway)";

    user = lib.mkOption {
      type = lib.types.str;
      default = "zeroclaw";
      description = "User to run ZeroClaw under.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = zeroclawPkg;
      description = "ZeroClaw package.";
    };

    runMode = lib.mkOption {
      type = lib.types.enum [
        "daemon"
        "gateway"
      ];
      default = "daemon";
      description = ''
        daemon: full runtime (gateway + channels + scheduler).
        gateway: webhook server only (default 127.0.0.1:42617).
      '';
    };

    # Файл с переменными окружения (например от sops-nix): ZEROCLAW_API_KEY, API_KEY и т.д.
    # Zeroclaw читает api_key из ZEROCLAW_API_KEY или API_KEY (см. config schema).
    secretsEnvFiles = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.path);
      default = null;
      example = lib.literalExpression ''config.sops.secrets."zeroclaw-env".path'';
      description = ''
        Путь к файлу с env (KEY=value), подключаемый как EnvironmentFile в systemd.
        Удобно указать секрет sops-nix, например:
        sops.secrets."zeroclaw-env" = { };
        services.zeroclaw.secretsEnvFiles = [config.sops.secrets."zeroclaw-env".path];
        Содержимое: ZEROCLAW_API_KEY=sk-... (и при необходимости другие ключи).
      '';
    };

    logLevel = lib.mkOption {
      type = lib.types.str;
      default = "trace";
      description = "Logging level.";
    };

    extraPkgs = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.nix
        pkgs.git
        pkgs.nodejs
        pkgs.cargo
        pkgs.rustc
        pkgs.python3
        pkgs.python313Packages.pip
        pkgs.gnumake
        pkgs.jq
      ];
      description = ''
        Packages whose `bin/` dirs are prepended to `PATH` for the `zeroclaw` systemd
        unit (same set is also added to `users.users.<user>.packages` when user is `zeroclaw`).
        Definitions are concatenated (defaults + extra modules + your `mkAfter` lists), not replaced.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    services.zeroclaw.settings.gateway.web_dist_dir = "${zeroclawWeb}";

    services.zeroclaw.extraPkgs = [
      # Defaults
      pkgs.nix
      pkgs.git
      pkgs.nodejs
      pkgs.cargo
      pkgs.rustc
      pkgs.python3
      pkgs.python313Packages.pip
      pkgs.gnumake
      pkgs.jq
    ];

    environment.systemPackages = [ cfg.package ];

    users.users = lib.optionalAttrs (cfg.user == "zeroclaw") {
      zeroclaw = {
        isSystemUser = true;
        group = "zeroclaw";
        home = cfg.dataDir;
        createHome = true;
        packages = cfg.extraPkgs;
      };
    };

    users.groups = lib.optionalAttrs (cfg.user == "zeroclaw") {
      zeroclaw = { };
    };

    systemd.services.zeroclaw = {
      description = "ZeroClaw AI assistant (${cfg.runMode})";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = lib.mkIf (cfg.user == "zeroclaw") "zeroclaw";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        RestartSec = "10s";
      }
      // lib.optionalAttrs (cfg.secretsEnvFiles != null) {
        EnvironmentFile = cfg.secretsEnvFiles;
      };

      environment = {
        RUST_LOG = cfg.logLevel;
        ZEROCLAW_CONFIG_DIR = cfg.dataDir;
      };

      path = [
        "/run/wrappers"
        "/run/current-system/sw"
      ]
      ++ cfg.extraPkgs;

      script = ''
        exec ${cfg.package}/bin/zeroclaw ${cfg.runMode}
      '';

      restartTriggers = [
        config.sops.templates."zeroclaw-config".path
        cfg.dataDir
        cfg.logLevel
        cfg.runMode
      ];
    };
  };
}
