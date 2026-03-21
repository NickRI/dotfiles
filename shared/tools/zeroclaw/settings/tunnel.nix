{ lib, ... }:
{
  options = {
    tunnel = lib.mkOption {
      type = lib.types.submodule {
        options = {
          cloudflare = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Cloudflare Tunnel configuration (used when `provider = \"cloudflare\"`).";
          };
          custom = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Custom tunnel command configuration (used when `provider = \"custom\"`).";
          };
          ngrok = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "ngrok tunnel configuration (used when `provider = \"ngrok\"`).";
          };
          openvpn = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "OpenVPN tunnel configuration (used when `provider = \"openvpn\"`).";
          };
          provider = lib.mkOption {
            type = lib.types.enum [
              "none"
              "cloudflare"
              "tailscale"
              "ngrok"
              "openvpn"
              "custom"
            ];
            default = "none";
            description = "Tunnel provider: `\"none\"`, `\"cloudflare\"`, `\"tailscale\"`, `\"ngrok\"`, `\"openvpn\"`, or `\"custom\"`. Default: `\"none\"`.";
          };
          tailscale = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Tailscale Funnel/Serve configuration (used when `provider = \"tailscale\"`).";
          };
        };
      };
      default = {
        provider = "none";
      };
      description = "Tunnel configuration for exposing the gateway publicly (`[tunnel]` section).\n\nSupported providers: `\"none\"` (default), `\"cloudflare\"`, `\"tailscale\"`, `\"ngrok\"`, `\"openvpn\"`, `\"custom\"`.";
    };
  };
}
