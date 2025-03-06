{ config, ... }:

{
  config = {
    services = {
      ollama.enable = true;
      open-webui = {
        enable = false;
        environment = {
          RAG_EMBEDDING_ENGINE = "ollama";
          ENABLE_SIGNUP = "True";
          ENV = "prod";
        };
      };
    };
  };
}
