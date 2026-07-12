{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };

  networking.firewall.trustedInterfaces = [
    "docker0"
    "ascend-br"
  ];

  services = {
    ollama = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      package = pkgs.unstable.ollama-rocm;
      environmentVariables = {
        OLLAMA_IGPU_ENABLE = "1";
        HSA_ENABLE_SDMA = "0";
        OLLAMA_DEBUG = "1";
      };

      group = [
        "video"
        "render"
      ];
    };

    open-webui = {
      enable = false;
      environment = {
        RAG_EMBEDDING_ENGINE = "ollama";
        ENABLE_SIGNUP = "True";
        ENV = "prod";
      };
    };
  };
}
