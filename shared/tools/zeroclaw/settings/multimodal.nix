{ lib, ... }:
{
  options = {
    multimodal = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allow_remote_fetch = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow fetching remote image URLs (http/https). Disabled by default.";
          };
          max_image_size_mb = lib.mkOption {
            type = lib.types.int;
            default = 5;
            description = "Maximum image payload size in MiB before base64 encoding.";
          };
          max_images = lib.mkOption {
            type = lib.types.int;
            default = 4;
            description = "Maximum number of image attachments accepted per request.";
          };
        };
      };
      default = {
        allow_remote_fetch = false;
        max_image_size_mb = 5;
        max_images = 4;
      };
      description = "Multimodal (image) handling configuration (`[multimodal]` section).";
    };
  };
}
