{
  config,
  pkgs,
  lib,
  ...
}:

let
  python-libzim = pkgs.python3Packages.buildPythonPackage rec {
    pname = "libzim";
    version = "3.12.0";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "openzim";
      repo = "python-libzim";
      rev = "v${version}";
      hash = "sha256-MysCc6yNFEZZPYLbe9uEDaWeCuejsSR6kuSME5KXiqY=";
    };

    env.USE_SYSTEM_LIBZIM = "1";
    env.DONT_DOWNLOAD_LIBZIM = "1";

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'setuptools == 83.0.0' 'setuptools' \
        --replace-fail 'wheel == 0.47.0' 'wheel' \
        --replace-fail 'cython == 3.2.8' 'cython'
    '';

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    build-system = with pkgs.python3Packages; [
      cython
      setuptools
      wheel
    ];

    buildInputs = [ pkgs.libzim ];

    doCheck = false;

    pythonImportsCheck = [ "libzim" ];

    meta = with lib; {
      description = "Python bindings for libzim";
      homepage = "https://github.com/openzim/python-libzim";
      license = licenses.gpl3Plus;
    };
  };

  zimi-pkg = pkgs.python3Packages.buildPythonApplication rec {
    pname = "zimi";
    version = "1.8.2";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "epheterson";
      repo = "Zimi";
      rev = "v${version}";
      hash = "sha256-O1ubShtX6VcKwjq7Fzll8fmDrmvj9T9GE/soBusxb18=";
    };

    build-system = with pkgs.python3Packages; [ setuptools ];

    dependencies = with pkgs.python3Packages; [
      python-libzim
      certifi
      zeroconf
      libtorrent-rasterbar
    ];

    pythonRelaxDeps = [
      "libzim"
      "zeroconf"
    ];
    pythonRemoveDeps = [ "libtorrent" ];

    postPatch = ''
      substituteInPlace zimi/server.py \
        --replace-fail 'ThreadingHTTPServer(("0.0.0.0", args.port), ZimHandler)' \
                       'ThreadingHTTPServer((os.environ.get("ZIMI_BIND", "127.0.0.1"), args.port), ZimHandler)'
    '';

    doCheck = false;

    meta = with lib; {
      description = "Offline knowledge server for ZIM files";
      homepage = "https://github.com/epheterson/Zimi";
      license = licenses.mit;
      mainProgram = "zimi";
    };
  };

  cfg = config.services.zimi;
  onOff = b: if b then "on" else "off";
  zimiBt =
    if !cfg.bitTorrent.enable then
      "off"
    else
      lib.concatStringsSep "," [
        "on"
        "port=${toString cfg.bitTorrent.port}"
        "ratio=${toString cfg.bitTorrent.ratio}"
        "up=${toString cfg.bitTorrent.up}"
        "seed=${onOff cfg.bitTorrent.seed}"
        "mirror=${onOff cfg.bitTorrent.mirror}"
        "upnp=${onOff cfg.bitTorrent.upnp}"
        "dht=${onOff cfg.bitTorrent.dht}"
      ];
  btSeeding = cfg.bitTorrent.enable && (cfg.bitTorrent.seed || cfg.bitTorrent.mirror);
in
{
  options.services.zimi = {
    enable = lib.mkEnableOption "Zimi ZIM server";

    package = lib.mkOption {
      type = lib.types.package;
      default = zimi-pkg;
      description = "Zimi package.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "zimi";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "zimi";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8899;
    };

    zimDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zimi/zims";
      description = "Directory with *.zim files (ZIM_DIR).";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zimi/config";
      description = "Cache, indexes, and settings (ZIMI_DATA_DIR).";
    };

    manage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Library manager (ZIMI_MANAGE).";
    };

    managePasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "File with ZIMI_MANAGE_PASSWORD (raw value).";
    };

    manageUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ZIMI_MANAGE_USER. Unset keeps the UI-controlled name.";
    };

    publicAccess = lib.mkOption {
      type = lib.types.enum [
        "open"
        "limited"
        "private"
      ];
      default = "open";
      description = "Anonymous access: open, limited allowlist, or private (sign-in).";
    };

    apiTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File with ZIMI_API_TOKEN. Unset lets Zimi generate one.";
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    updateFreq = lib.mkOption {
      type = lib.types.enum [
        "daily"
        "weekly"
        "monthly"
      ];
      default = "weekly";
    };

    hotZims = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "ZIM names to pre-warm at startup (ZIMI_HOT_ZIMS).";
    };

    bitTorrent = {
      enable = lib.mkEnableOption "BitTorrent engine (ZIMI_BT)";

      port = lib.mkOption {
        type = lib.types.port;
        default = 6881;
      };

      seed = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Seed downloads. Opens firewall on bitTorrent.port when true.";
      };

      mirror = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Full Kiwix mirror. Opens firewall on bitTorrent.port when true.";
      };

      ratio = lib.mkOption {
        type = lib.types.number;
        default = 2;
        description = "Seed ratio cap. 0 means never seed.";
      };

      up = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2048;
        description = "Upload limit in KiB/s.";
      };

      upnp = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      dht = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };

    nearby = lib.mkOption {
      type = lib.types.str;
      default = "off";
      example = "on,name=nas-zimi,public=off";
      description = "LAN sharing blob (ZIMI_NEARBY).";
    };

    maxConcurrentDownloads = lib.mkOption {
      type = lib.types.ints.between 1 20;
      default = 4;
      description = "Parallel ZIM downloads, HTTP and BitTorrent (ZIMI_MAX_CONCURRENT_DOWNLOADS).";
    };

    dlWindow = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "02:00-06:00";
      description = "Download window HH:MM-HH:MM (ZIMI_DL_WINDOW). Unset leaves UI control.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables passed to the service.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == "zimi") {
      zimi = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "zimi") {
      zimi = { };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.zimDir} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
    ];

    networking.firewall = lib.mkIf btSeeding {
      allowedTCPPorts = [ cfg.bitTorrent.port ];
      allowedUDPPorts = [ cfg.bitTorrent.port ];
    };

    systemd.services.zimi = {
      description = "Zimi ZIM server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        ZIM_DIR = cfg.zimDir;
        ZIMI_DATA_DIR = cfg.dataDir;
        ZIMI_BIND = cfg.listenAddress;
        ZIMI_MANAGE = if cfg.manage then "1" else "0";
        ZIMI_PUBLIC_ACCESS = cfg.publicAccess;
        ZIMI_AUTO_UPDATE = if cfg.autoUpdate then "1" else "0";
        ZIMI_UPDATE_FREQ = cfg.updateFreq;
        ZIMI_BT = zimiBt;
        ZIMI_NEARBY = cfg.nearby;
        ZIMI_MAX_CONCURRENT_DOWNLOADS = toString cfg.maxConcurrentDownloads;
      }
      // lib.optionalAttrs (cfg.manageUser != null) {
        ZIMI_MANAGE_USER = cfg.manageUser;
      }
      // lib.optionalAttrs (cfg.hotZims != [ ]) {
        ZIMI_HOT_ZIMS = lib.concatStringsSep "," cfg.hotZims;
      }
      // lib.optionalAttrs (cfg.dlWindow != null) {
        ZIMI_DL_WINDOW = cfg.dlWindow;
      }
      // cfg.extraEnvironment;

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";
        WorkingDirectory = cfg.dataDir;
      };

      script = ''
        export ZIMI_MANAGE_PASSWORD=$(cat ${cfg.managePasswordFile})
        ${lib.optionalString (cfg.apiTokenFile != null) ''
          export ZIMI_API_TOKEN=$(cat ${cfg.apiTokenFile})
        ''}
        exec ${cfg.package}/bin/zimi serve --port ${toString cfg.port}
      '';

      restartTriggers = [
        cfg.listenAddress
        (toString cfg.port)
        cfg.zimDir
        cfg.dataDir
        (toString cfg.manage)
        cfg.publicAccess
        (toString cfg.autoUpdate)
        cfg.updateFreq
        zimiBt
        cfg.nearby
        (toString cfg.maxConcurrentDownloads)
      ];
    };
  };
}
