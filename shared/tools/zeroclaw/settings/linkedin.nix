{ lib, ... }:
{
  options = {
    linkedin = lib.mkOption {
      type = lib.types.submodule {
        options = {
          api_version = lib.mkOption {
            type = lib.types.str;
            default = "202602";
            description = "LinkedIn REST API version header (YYYYMM format).";
          };
          content = lib.mkOption {
            type = lib.types.submodule {
              options = {
                github_repos = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "GitHub repositories to highlight (format: `owner/repo`).";
                };
                github_users = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "GitHub usernames whose public activity to reference.";
                };
                instructions = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Freeform posting instructions for the AI agent.";
                };
                persona = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Professional persona description (name, role, expertise).";
                };
                rss_feeds = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "RSS feed URLs to monitor for topic inspiration (titles only).";
                };
                topics = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Topics of expertise and interest for post themes.";
                };
              };
            };
            default = {
              github_repos = [ ];
              github_users = [ ];
              instructions = "";
              persona = "";
              rss_feeds = [ ];
              topics = [ ];
            };
            description = "Content strategy configuration for LinkedIn auto-posting (`[linkedin.content]`).\n\nThe agent reads this via the `linkedin get_content_strategy` action to know\nwhat feeds to check, which repos to highlight, and how to write posts.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the LinkedIn tool.";
          };
          image = lib.mkOption {
            type = lib.types.submodule {
              options = {
                card_accent_color = lib.mkOption {
                  type = lib.types.str;
                  default = "#0A66C2";
                  description = "Accent color for the fallback card (CSS hex).";
                };
                dalle = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      api_key_env = lib.mkOption {
                        type = lib.types.str;
                        default = "OPENAI_API_KEY";
                        description = "Environment variable name holding the OpenAI API key.";
                      };
                      model = lib.mkOption {
                        type = lib.types.str;
                        default = "dall-e-3";
                        description = "DALL-E model identifier.";
                      };
                      size = lib.mkOption {
                        type = lib.types.str;
                        default = "1024x1024";
                        description = "Image dimensions.";
                      };
                    };
                  };
                  default = {
                    api_key_env = "OPENAI_API_KEY";
                    model = "dall-e-3";
                    size = "1024x1024";
                  };
                  description = "OpenAI DALL-E settings (`[linkedin.image.dalle]`).";
                };
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable image generation for posts.";
                };
                fallback_card = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Generate a branded SVG text card when all AI providers fail.";
                };
                flux = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      api_key_env = lib.mkOption {
                        type = lib.types.str;
                        default = "FAL_API_KEY";
                        description = "Environment variable name holding the fal.ai API key.";
                      };
                      model = lib.mkOption {
                        type = lib.types.str;
                        default = "fal-ai/flux/schnell";
                        description = "Flux model identifier.";
                      };
                    };
                  };
                  default = {
                    api_key_env = "FAL_API_KEY";
                    model = "fal-ai/flux/schnell";
                  };
                  description = "Flux (fal.ai) image generation settings (`[linkedin.image.flux]`).";
                };
                imagen = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      api_key_env = lib.mkOption {
                        type = lib.types.str;
                        default = "GOOGLE_VERTEX_API_KEY";
                        description = "Environment variable name holding the API key.";
                      };
                      project_id_env = lib.mkOption {
                        type = lib.types.str;
                        default = "GOOGLE_CLOUD_PROJECT";
                        description = "Environment variable for the Google Cloud project ID.";
                      };
                      region = lib.mkOption {
                        type = lib.types.str;
                        default = "us-central1";
                        description = "Vertex AI region.";
                      };
                    };
                  };
                  default = {
                    api_key_env = "GOOGLE_VERTEX_API_KEY";
                    project_id_env = "GOOGLE_CLOUD_PROJECT";
                    region = "us-central1";
                  };
                  description = "Google Imagen (Vertex AI) settings (`[linkedin.image.imagen]`).";
                };
                providers = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [ ];
                  description = "Provider priority order. Tried in sequence; first success wins.";
                };
                stability = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      api_key_env = lib.mkOption {
                        type = lib.types.str;
                        default = "STABILITY_API_KEY";
                        description = "Environment variable name holding the API key.";
                      };
                      model = lib.mkOption {
                        type = lib.types.str;
                        default = "stable-diffusion-xl-1024-v1-0";
                        description = "Stability model identifier.";
                      };
                    };
                  };
                  default = {
                    api_key_env = "STABILITY_API_KEY";
                    model = "stable-diffusion-xl-1024-v1-0";
                  };
                  description = "Stability AI image generation settings (`[linkedin.image.stability]`).";
                };
                temp_dir = lib.mkOption {
                  type = lib.types.str;
                  default = "linkedin/images";
                  description = "Temp directory for generated images, relative to workspace.";
                };
              };
            };
            default = {
              card_accent_color = "#0A66C2";
              dalle = {
                api_key_env = "OPENAI_API_KEY";
                model = "dall-e-3";
                size = "1024x1024";
              };
              enabled = false;
              fallback_card = true;
              flux = {
                api_key_env = "FAL_API_KEY";
                model = "fal-ai/flux/schnell";
              };
              imagen = {
                api_key_env = "GOOGLE_VERTEX_API_KEY";
                project_id_env = "GOOGLE_CLOUD_PROJECT";
                region = "us-central1";
              };
              providers = [
                "stability"
                "imagen"
                "dalle"
                "flux"
              ];
              stability = {
                api_key_env = "STABILITY_API_KEY";
                model = "stable-diffusion-xl-1024-v1-0";
              };
              temp_dir = "linkedin/images";
            };
            description = "Image generation configuration for LinkedIn posts (`[linkedin.image]`).";
          };
        };
      };
      default = {
        api_version = "202602";
        content = {
          github_repos = [ ];
          github_users = [ ];
          instructions = "";
          persona = "";
          rss_feeds = [ ];
          topics = [ ];
        };
        enabled = false;
        image = {
          card_accent_color = "#0A66C2";
          dalle = {
            api_key_env = "OPENAI_API_KEY";
            model = "dall-e-3";
            size = "1024x1024";
          };
          enabled = false;
          fallback_card = true;
          flux = {
            api_key_env = "FAL_API_KEY";
            model = "fal-ai/flux/schnell";
          };
          imagen = {
            api_key_env = "GOOGLE_VERTEX_API_KEY";
            project_id_env = "GOOGLE_CLOUD_PROJECT";
            region = "us-central1";
          };
          providers = [
            "stability"
            "imagen"
            "dalle"
            "flux"
          ];
          stability = {
            api_key_env = "STABILITY_API_KEY";
            model = "stable-diffusion-xl-1024-v1-0";
          };
          temp_dir = "linkedin/images";
        };
      };
      description = "LinkedIn integration configuration (`[linkedin]` section).\n\nWhen enabled, the `linkedin` tool is registered in the agent tool surface.\nRequires `LINKEDIN_*` credentials in the workspace `.env` file.";
    };
  };
}
