{
  config,
  pkgs,
  lib,
  ...
}:

let
  python = pkgs.python3.withPackages (
    ps: with ps; [
      flask
      requests
      uvicorn
      asgiref
    ]
  );

  docker-registry-ui-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "docker-registry-ui";
    version = "main";

    src = pkgs.fetchFromGitHub {
      owner = "VibhuviOiO";
      repo = "docker-registry-ui";
      rev = "${version}";
      hash = "sha256-at+M9DIJYkhPK2KoeyVHul3y4FuChqjzyS2+retKc4c=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ python ];

    installPhase = ''
      runHook preInstall
      share=$out/share/docker-registry-ui
      mkdir -p $share $out/bin
      cp -r app templates static asgi.py $share/
      makeWrapper ${python}/bin/uvicorn $out/bin/docker-registry-ui \
        --argv0 "docker-registry-ui" \
        --set PYTHONPATH "$share" \
        --add-flags "asgi:app"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Web UI for Docker Registry";
      homepage = "https://github.com/VibhuviOiO/docker-registry-ui";
      license = licenses.mit;
      maintainers = [ ];
    };
  };

  cfg = config.services.docker-registry-ui;
in
{

  options.services.docker-registry-ui = {
    enable = lib.mkEnableOption "Docker Registry UI";

    user = lib.mkOption {
      type = lib.types.str;
      default = "docker-registry";
      example = "<cusrtom_user>";
    };
    path = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/docker-registry/ui";
      example = "<your_path>";
    };
    listen-address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8094;
      example = 8084;
    };
    registries = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        {
          name = "Local Registry";
          api = "http://127.0.0.1:5000";
          default = true;
          bulkOperationsEnabled = true;
          vulnerabilityScan = {
            enabled = true;
            scanner = "trivy";
            scannerUrl = "";
            autoScanRules = [ ];
            scanLatestOnly = 1;
          };
        }
      ];
    };
    configFile = lib.mkOption {
      default = pkgs.writeText "registries.json" (builtins.toJSON cfg.registries);
      defaultText = lib.literalExpression ''pkgs.writeText "registries.json" "# my custom registries.json ..."'';
      description = "Path to registries config";
      type = lib.types.path;
    };
    trivy-install = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Install trivy scanner for vulnerabilities in container images";
    };
  };

  config = lib.mkIf cfg.enable {
    # We need to set not on the /nix/store to write operations to detect /app path
    system.activationScripts.registryUiSymlink = {
      text = ''
        mkdir -p ${cfg.path}
        chown ${cfg.user}:${cfg.user} ${cfg.path}
        ln -sf ${cfg.configFile} ${cfg.path}/ui-config.json
      '';
    };

    systemd.services.docker-registry-ui = {
      description = "Docker Registry UI (VibhuviOiO/docker-registry-ui)";
      after = [ "docker-registry.service" ];
      wants = [ "docker-registry.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        WorkingDirectory = cfg.path;
      };
      environment = {
        CONFIG_FILE = "${cfg.path}/ui-config.json";
        READ_ONLY = "false";
        CHECK_INTERVAL = "300";
        TIMEOUT = "10";
        BUILT_BY = "NixOS";
      };
      script = ''
        export PATH="${pkgs.trivy}/bin:$PATH"
        exec ${docker-registry-ui-pkg}/bin/docker-registry-ui \
          --host ${cfg.listen-address} \
          --port ${toString cfg.port} \
          --log-level info
      '';
      restartTriggers = [
        cfg.configFile
        cfg.listen-address
        cfg.path
        cfg.user
        cfg.port
      ];
    };

    systemd.services.docker-registry-ui.path = lib.mkIf cfg.trivy-install [
      "${pkgs.trivy}/bin"
    ];
  };
}
