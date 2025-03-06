{ config, lib, ... }:

{
  config = {
    services.flatpak.packages = lib.mkIf (config.services.flatpak.enable) [ "com.surfshark.Surfshark" ];

    programs.chromium = lib.mkIf (config.programs.chromium.enable) {
      extensions = [
        { id = "ailoabdmgclmfmhdagmlohpjlbpffblp"; } # Surfshark VPN
      ];
    };
  };
}
