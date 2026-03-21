{ lib, ... }:
{
  options = {
    node_transport = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed_peers = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Allow specific node IPs/CIDRs.";
          };
          connection_pool_size = lib.mkOption {
            type = lib.types.int;
            default = 4;
            description = "Maximum number of connections per peer.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the secure transport layer.";
          };
          max_request_age_secs = lib.mkOption {
            type = lib.types.int;
            default = 300;
            description = "Maximum age of signed requests in seconds (replay protection).";
          };
          mutual_tls = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Require client certificates (mutual TLS).";
          };
          require_https = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Require HTTPS for all node communication.";
          };
          shared_secret = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Shared secret for HMAC authentication between nodes.";
          };
          tls_cert_path = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Path to TLS certificate file.";
          };
          tls_key_path = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            default = null;
            description = "Path to TLS private key file.";
          };
        };
      };
      default = {
        allowed_peers = [ ];
        connection_pool_size = 4;
        enabled = true;
        max_request_age_secs = 300;
        mutual_tls = false;
        require_https = true;
        shared_secret = "";
      };
      description = "Secure transport configuration for inter-node communication (`[node_transport]`).";
    };
  };
}
