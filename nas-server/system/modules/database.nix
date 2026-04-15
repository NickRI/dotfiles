{
  config,
  nixpkgs-unstable,
  pkgs,
  lib,
  ...
}:

{
  services = {
    gatus.settings.endpoints = [
      {
        name = "postgres";
        url = "tcp://127.0.0.1:5432";
        group = "databases";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] < 10"
        ];
      }
      {
        name = "neo4j";
        url = "tcp://127.0.0.1:7474";
        group = "databases";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] < 10"
        ];
      }
      {
        name = "redis";
        url = "tcp://127.0.0.1:${toString config.services.redis.servers.master.port}";
        group = "databases";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] < 10"
        ];
      }
    ];

    redis = {
      servers.master = {
        enable = true;
        openFirewall = true;
        bind = "0.0.0.0";
        port = 6379;
      };
    };

    postgresql = {
      dataDir = "/storage/postgresql";

      settings = {
        listen_addresses = lib.mkForce "*";
        password_encryption = "scram-sha-256";
      };

      ensureDatabases = [ "lightrag" ];
      ensureUsers = [
        {
          name = "lightrag";
          ensureDBOwnership = true;
        }
      ];

      authentication = pkgs.lib.mkOverride 10 ''
        #Type   Database  DBuser  Network       auth-method
        local   all       all                   trust
        host    all       all   127.0.0.1/32    trust
        host    all       all     ::1/128       trust
        host    all       all  192.168.1.0/24   scram-sha-256
      '';
    };

    neo4j = {
      enable = true;
      bolt.tlsLevel = "DISABLED";
      https.enable = false;
      defaultListenAddress = "0.0.0.0";
      directories.home = "/storage/neo4j";
      extraServerConfig = ''
        dbms.connector.bolt.tls_level = DISABLED
        dbms.security.procedures.allowlist = apoc.*
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    5432
    7687
  ];
}
