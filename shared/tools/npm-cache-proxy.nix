# Модуль-библиотека для NPM caching proxy (https://github.com/stackdumper/npm-cache-proxy).
# Прокси к registry.npmjs.org с кешем в Redis.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  npm-cache-proxy-pkg = pkgs.buildGoModule {
    pname = "npm-cache-proxy";
    version = "0.1.3";
    src = pkgs.fetchFromGitHub {
      owner = "stackdumper";
      repo = "npm-cache-proxy";
      rev = "fa1c796f3c2677e8c702d2fc8d1bc7ca44e4e185";
      hash = "";
    };
    vendorHash = lib.fakeSha256;
  };

  cfg = config.services.npm-cache-proxy;
in
{
  options.services.npm-cache-proxy = {
    enable = lib.mkEnableOption "NPM caching proxy (ncp) with Redis";

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8531;
      description = "Port to listen on (e.g. for nginx proxy).";
    };

    upstream = lib.mkOption {
      type = lib.types.str;
      default = "https://registry.npmjs.org";
      description = "Upstream npm registry URL.";
    };

    redis = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:6380";
        description = "Redis address for cache storage.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 6380;
        description = "Port for the dedicated Redis instance (used only if enableDedicatedRedis).";
      };
      database = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Redis database number.";
      };
      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Redis password (null if none).";
      };
      prefix = lib.mkOption {
        type = lib.types.str;
        default = "ncp-";
        description = "Redis key prefix.";
      };
    };

    cacheTtl = lib.mkOption {
      type = lib.types.int;
      default = 3600;
      description = "Cache TTL in seconds.";
    };

    silent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable request logs.";
    };

    enableDedicatedRedis = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run a dedicated Redis instance for ncp. If false, you must set redis.address to an existing Redis.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.enableDedicatedRedis {
        services.redis.servers.npm-cache-proxy = {
          enable = true;
          port = cfg.redis.port;
          bind = "127.0.0.1";
        };
      })
      {

        systemd.services.npm-cache-proxy = {
          description = "NPM caching proxy (ncp)";
          after = lib.optional cfg.enableDedicatedRedis "redis-npm-cache-proxy.service";
          wants = lib.optional cfg.enableDedicatedRedis "redis-npm-cache-proxy.service";

          serviceConfig.Restart = "on-failure";

          script = ''
            export LISTEN_ADDRESS=127.0.0.1:${toString cfg.listenPort}
            export UPSTREAM_ADDRESS=${cfg.upstream}
            export REDIS_ADDRESS=${cfg.redis.address}
            export REDIS_DATABASE=${toString cfg.redis.database}
            export REDIS_PREFIX=${cfg.redis.prefix}
            export CACHE_TTL=${toString cfg.cacheTtl}
            export SILENT=${if cfg.silent then "1" else "0"}
            ${lib.optionalString (cfg.redis.password != null) "export REDIS_PASSWORD=${cfg.redis.password}"}
            exec ${npm-cache-proxy-pkg}/bin/ncp
          '';
        };
      }
    ]
  );
}
