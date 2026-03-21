{ lib, ... }:
{
  options = {
    cloud_ops = lib.mkOption {
      type = lib.types.submodule {
        options = {
          cost_threshold_monthly_usd = lib.mkOption {
            type = lib.types.float;
            default = 100.0;
            description = "Monthly USD threshold to flag cost items. Default: 100.0.";
          };
          default_cloud = lib.mkOption {
            type = lib.types.enum [
              "aws"
              "azure"
              "gcp"
            ];
            default = "aws";
            description = "Облако по умолчанию для cloud_ops.";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable cloud operations tools. Default: false.";
          };
          iac_tools = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Supported IaC tools for review. Default: [`terraform`].";
          };
          supported_clouds = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Supported cloud providers. Default: [`aws`, `azure`, `gcp`].";
          };
          well_architected_frameworks = lib.mkOption {
            type = (lib.types.listOf (lib.types.str));
            default = [ ];
            description = "Well-Architected Frameworks to check against. Default: [`aws-waf`].";
          };
        };
      };
      default = {
        cost_threshold_monthly_usd = 100.0;
        default_cloud = "aws";
        enabled = false;
        iac_tools = [ "terraform" ];
        supported_clouds = [ ];
        well_architected_frameworks = [ "aws-waf" ];
      };
      description = "Controls the read-only cloud transformation analysis tools:\nIaC review, migration assessment, cost analysis, and architecture review.";
    };
  };
}
