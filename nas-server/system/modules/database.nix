{
  config,
  pkgs,
  lib,
  ...
}:

{
  services = {
    postgresql = {
      dataDir = "/storage/postgresql";

      authentication = pkgs.lib.mkOverride 10 ''
        #Type   Database  DBuser  Network       auth-method
        local   all       all                   trust
        host    all       all     127.0.0.1/32  trust
        host    all       all     ::1/128       trust
      '';
    };
  };
}
