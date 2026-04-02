{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services = {
    ollama = {
      enable = true;
      package = pkgs.unstable.ollama-rocm;
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0";
        HSA_ENABLE_SDMA = "0";
        OLLAMA_DEBUG = "1";
      };

      group = [
        "video"
        "render"
      ];

      rocmOverrideGfx = "11.0.0";
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
